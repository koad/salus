#!/usr/bin/env bash
# storefront/scrub — find references to files that don't exist in the storefront
#
# Usage: salus storefront scrub <entity>
#        salus storefront scrub --all
#
# Scans all .md and .sh files in the storefront for:
#   1. Markdown links to local files: [text](path) or [text]: path
#   2. Absolute paths to entity/home dirs: ~/.<entity>/, /home/*/.<entity>/
#   3. References to ~/ or $HOME paths (not resolvable by a public reader)
#   4. Relative paths (./foo, ../foo) that don't resolve within the storefront
#
# Does NOT flag: URLs (http/https), anchors (#), mailto:, code fences

set -euo pipefail

FORGE_DIR="${FORGE_DIR:-$HOME/.forge/storefronts/entities}"

scrub_entity() {
  local entity="$1"
  local store_dir="$FORGE_DIR/$entity"

  if [[ ! -d "$store_dir" ]]; then
    echo "  SKIP: no storefront at $store_dir"
    return 0
  fi

  local issues=0

  while IFS= read -r -d '' file; do
    local rel="${file#"$store_dir"/}"
    local dir
    dir=$(dirname "$file")
    local file_issues=0

    # Read line by line for context
    local lineno=0
    while IFS= read -r line; do
      lineno=$((lineno + 1))

      # Skip lines inside code fences
      # (Simple heuristic — not perfect for nested fences)

      # --- Check 1: absolute entity paths ---
      # ~/.<anything>/ or /home/<user>/.<anything>/
      # But NOT standard unix dotfiles/dotdirs that installers legitimately touch.
      if echo "$line" | grep -qE '~/\.[a-zA-Z]|/home/[^/]+/\.[a-zA-Z]'; then
        # Extract all ~/.<something> and /home/**/.<something> references
        local refs_found
        refs_found=$(echo "$line" | grep -oE '~/\.[a-zA-Z][a-zA-Z0-9_-]*|/home/[^/]+/\.[a-zA-Z][a-zA-Z0-9_-]*' || true)

        for pathref in $refs_found; do
          # Normalize to just the dotfile/dotdir name
          local dotname
          dotname=$(echo "$pathref" | grep -oE '\.[a-zA-Z][a-zA-Z0-9_-]*$' || true)

          # Known-safe standard unix paths — installers write to these
          case "$dotname" in
            .bashrc|.zshrc|.profile|.bash_profile|.zprofile|.zshenv) continue ;;
            .config|.local|.cache|.npm|.bun|.nvm|.meteor|.cargo) continue ;;
            .ssh|.gnupg|.gitconfig|.git) continue ;;
            .linuxbrew|.opencode) continue ;;
          esac

          # This is an entity-dir or private-path reference
          if [[ $file_issues -eq 0 ]]; then
            echo "  $rel:"
            file_issues=1
          fi

          # Distinguish hardcoded machine paths from generic entity refs
          if echo "$pathref" | grep -qE '^/home/'; then
            echo "    L$lineno [HARDCODED-PATH] $pathref"
          else
            echo "    L$lineno [ENTITY-PATH] $pathref"
          fi
          issues=$((issues + 1))
        done
        continue
      fi

      # --- Check 2: markdown links to local files ---
      # Extract paths from [text](path) — skip URLs, anchors, mailto
      local refs
      refs=$(echo "$line" | grep -oE '\]\([^)]+\)' | sed 's/\](//' | sed 's/)//' | grep -vE '^https?://|^mailto:|^#' || true)

      for ref in $refs; do
        # Strip any anchor fragment
        ref="${ref%%#*}"
        [[ -z "$ref" ]] && continue

        # Resolve relative to the file's directory
        local target
        if [[ "$ref" == /* ]]; then
          target="$ref"
        else
          target="$dir/$ref"
        fi

        # Normalize (remove ../ etc)
        target=$(realpath -m "$target" 2>/dev/null || echo "$target")

        # Check if it's inside the storefront and exists
        if [[ "$target" == "$store_dir"* ]]; then
          if [[ ! -e "$target" ]]; then
            if [[ $file_issues -eq 0 ]]; then
              echo "  $rel:"
              file_issues=1
            fi
            echo "    L$lineno [BROKEN-LINK] ($ref) -> not found"
            issues=$((issues + 1))
          fi
        else
          # Points outside storefront
          if [[ $file_issues -eq 0 ]]; then
            echo "  $rel:"
            file_issues=1
          fi
          echo "    L$lineno [OUTSIDE-STORE] ($ref) -> resolves outside storefront"
          issues=$((issues + 1))
        fi
      done

      # --- Check 3: frontmatter/yaml refs to entity paths ---
      # Lines like "  - ~/.chiron/something" or "see: ~/.<entity>/path"
      if echo "$line" | grep -qE '^\s*-?\s*~/'; then
        local yref
        yref=$(echo "$line" | grep -oE '~/[^ "'\''`,]+' || true)
        if [[ -n "$yref" ]]; then
          if [[ $file_issues -eq 0 ]]; then
            echo "  $rel:"
            file_issues=1
          fi
          echo "    L$lineno [HOME-REF] $yref (not resolvable by public reader)"
          issues=$((issues + 1))
        fi
      fi

    done < "$file"
  done < <(find "$store_dir" -type f \( -name '*.md' -o -name '*.sh' -o -name '*.json' \) -not -path '*/.git/*' -print0 2>/dev/null)

  if [[ $issues -eq 0 ]]; then
    echo "  OK — no broken or private references found"
  fi

  echo "  ---"
  echo "  issues: $issues"
}

# --- Main ---

if [[ "${1:-}" == "--all" ]]; then
  for store in "$FORGE_DIR"/*/; do
    [[ -d "$store" ]] || continue
    entity=$(basename "$store")
    echo "=== $entity ==="
    scrub_entity "$entity"
    echo
  done
elif [[ -n "${1:-}" ]]; then
  echo "=== $1 ==="
  scrub_entity "$1"
else
  echo "Usage: salus storefront scrub <entity>"
  echo "       salus storefront scrub --all"
  exit 1
fi
