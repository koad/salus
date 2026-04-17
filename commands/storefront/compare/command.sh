#!/usr/bin/env bash
# storefront/compare — diff entity dir against its storefront projection
#
# Usage: salus storefront compare <entity>
#        salus storefront compare --all
#
# Compares ~/.forge/storefronts/entities/<entity>/ against ~/.<entity>/
# using the storefront whitelist. Reports:
#   1. Files in storefront that are NOT on the whitelist (shouldn't be there)
#   2. Files on the whitelist that differ between entity and storefront
#   3. Files on the whitelist that are missing from the storefront

set -euo pipefail

FORGE_DIR="${FORGE_DIR:-$HOME/.forge/storefronts/entities}"

# --- Whitelist ---
# These are the files/patterns that belong in a storefront.
# Patterns ending in / are directory prefixes.
WHITELIST=(
  "ENTITY.md"
  "README.md"
  "LICENSE"
  "KOAD_IO_VERSION"
  "PRIMER.md"
  "passenger.json"
  "commands/"
  "hooks/"
  "sigchain/"
  "id/*.pub"
  "curriculum/"
  ".env.example"
  ".gitignore"
)

# --- Helpers ---

is_whitelisted() {
  local rel="$1"
  for pattern in "${WHITELIST[@]}"; do
    case "$pattern" in
      */)
        # directory prefix match
        [[ "$rel" == "$pattern"* ]] && return 0
        ;;
      *\**)
        # glob match
        local dir="${pattern%/*}"
        local glob="${pattern##*/}"
        if [[ "$rel" == "$dir/"* ]]; then
          local base="${rel#"$dir"/}"
          # shellcheck disable=SC2254
          case "$base" in $glob) return 0 ;; esac
        fi
        ;;
      *)
        # exact match
        [[ "$rel" == "$pattern" ]] && return 0
        ;;
    esac
  done
  return 1
}

compare_entity() {
  local entity="$1"
  local entity_dir="$HOME/.$entity"
  local store_dir="$FORGE_DIR/$entity"

  if [[ ! -d "$entity_dir" ]]; then
    echo "  ERROR: entity dir $entity_dir does not exist"
    return 1
  fi
  if [[ ! -d "$store_dir" ]]; then
    echo "  SKIP: no storefront at $store_dir"
    return 0
  fi

  local violations=0
  local diffs=0
  local missing=0

  # 1. Files in storefront NOT on whitelist
  while IFS= read -r -d '' f; do
    local rel="${f#"$store_dir"/}"
    [[ "$rel" == .git* ]] && continue
    if ! is_whitelisted "$rel"; then
      if [[ $violations -eq 0 ]]; then
        echo "  NOT ON WHITELIST (should not be in storefront):"
      fi
      echo "    - $rel"
      violations=$((violations + 1))
    fi
  done < <(find "$store_dir" -type f -not -path '*/.git/*' -print0 2>/dev/null)

  # 2. Files on whitelist that differ
  while IFS= read -r -d '' f; do
    local rel="${f#"$store_dir"/}"
    [[ "$rel" == .git* ]] && continue
    if is_whitelisted "$rel" && [[ -f "$entity_dir/$rel" ]]; then
      if ! cmp -s "$entity_dir/$rel" "$store_dir/$rel"; then
        if [[ $diffs -eq 0 ]]; then
          echo "  DIFFERS (entity vs storefront):"
        fi
        echo "    - $rel"
        diff --color=auto -u "$store_dir/$rel" "$entity_dir/$rel" 2>/dev/null | head -20 | sed 's/^/      /' || true
        diffs=$((diffs + 1))
      fi
    fi
  done < <(find "$store_dir" -type f -not -path '*/.git/*' -print0 2>/dev/null)

  # 3. Whitelisted files missing from storefront but present in entity
  for pattern in "${WHITELIST[@]}"; do
    case "$pattern" in
      */)
        # directory — check if entity has it but storefront doesn't
        if [[ -d "$entity_dir/$pattern" ]] && [[ ! -d "$store_dir/$pattern" ]]; then
          if [[ $missing -eq 0 ]]; then
            echo "  MISSING FROM STOREFRONT:"
          fi
          echo "    - $pattern (directory exists in entity)"
          missing=$((missing + 1))
        fi
        ;;
      *\**)
        # glob — expand in entity dir, check storefront
        local dir="${pattern%/*}"
        if [[ -d "$entity_dir/$dir" ]]; then
          for ef in "$entity_dir"/$pattern; do
            [[ -f "$ef" ]] || continue
            local rel="${ef#"$entity_dir"/}"
            if [[ ! -f "$store_dir/$rel" ]]; then
              if [[ $missing -eq 0 ]]; then
                echo "  MISSING FROM STOREFRONT:"
              fi
              echo "    - $rel"
              missing=$((missing + 1))
            fi
          done
        fi
        ;;
      *)
        # exact file
        if [[ -f "$entity_dir/$pattern" ]] && [[ ! -f "$store_dir/$pattern" ]]; then
          if [[ $missing -eq 0 ]]; then
            echo "  MISSING FROM STOREFRONT:"
          fi
          echo "    - $pattern"
          missing=$((missing + 1))
        fi
        ;;
    esac
  done

  if [[ $violations -eq 0 ]] && [[ $diffs -eq 0 ]] && [[ $missing -eq 0 ]]; then
    echo "  OK — storefront matches entity whitelist"
  fi

  echo "  ---"
  echo "  violations: $violations | diffs: $diffs | missing: $missing"
}

# --- Main ---

if [[ "${1:-}" == "--all" ]]; then
  for store in "$FORGE_DIR"/*/; do
    [[ -d "$store" ]] || continue
    entity=$(basename "$store")
    echo "=== $entity ==="
    compare_entity "$entity"
    echo
  done
elif [[ -n "${1:-}" ]]; then
  echo "=== $1 ==="
  compare_entity "$1"
else
  echo "Usage: salus storefront compare <entity>"
  echo "       salus storefront compare --all"
  exit 1
fi
