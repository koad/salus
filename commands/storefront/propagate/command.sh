#!/usr/bin/env bash
# storefront/propagate — sync whitelisted files from entity into storefront
#
# Usage: salus storefront propagate <entity>
#        salus storefront propagate --all
#
# For each entity:
#   1. Removes files from storefront that aren't on the whitelist
#   2. Copies whitelisted files from entity dir to storefront
#   3. Leaves changes staged but NOT committed — each entity commits its own
#
# Authorship rule: Salus never commits to a storefront. She prepares the
# filesystem state; the entity commits its own public face.

set -euo pipefail

FORGE_DIR="${FORGE_DIR:-$HOME/.forge/storefronts/entities}"

# --- Whitelist (same as compare/scrub) ---
WHITELIST_FILES=(
  "ENTITY.md"
  "README.md"
  "LICENSE"
  "KOAD_IO_VERSION"
  "PRIMER.md"
  "passenger.json"
  ".gitignore"
  ".env.example"
)
WHITELIST_DIRS=(
  "commands"
  "hooks"
  "sigchain"
  "curriculum"
)
# id/*.pub handled specially (public keys only)

propagate_entity() {
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

  local removed=0
  local copied=0
  local dirs_synced=0

  # --- Step 1: Remove non-whitelisted files from storefront ---
  while IFS= read -r -d '' f; do
    local rel="${f#"$store_dir"/}"
    [[ "$rel" == .git/* ]] && continue

    local keep=0

    # Check whitelist files
    for wf in "${WHITELIST_FILES[@]}"; do
      [[ "$rel" == "$wf" ]] && keep=1 && break
    done

    # Check whitelist dirs
    if [[ $keep -eq 0 ]]; then
      for wd in "${WHITELIST_DIRS[@]}"; do
        [[ "$rel" == "$wd"/* ]] && keep=1 && break
      done
    fi

    # Check id/*.pub
    if [[ $keep -eq 0 ]] && [[ "$rel" == id/*.pub ]]; then
      keep=1
    fi

    if [[ $keep -eq 0 ]]; then
      rm "$f"
      echo "    removed: $rel"
      removed=$((removed + 1))
    fi
  done < <(find "$store_dir" -type f -not -path '*/.git/*' -print0 2>/dev/null)

  # Clean up empty directories
  find "$store_dir" -mindepth 1 -type d -not -path '*/.git*' -empty -delete 2>/dev/null || true

  # --- Step 2: Copy whitelisted files from entity to storefront ---
  for wf in "${WHITELIST_FILES[@]}"; do
    if [[ -f "$entity_dir/$wf" ]]; then
      mkdir -p "$(dirname "$store_dir/$wf")"
      if ! cmp -s "$entity_dir/$wf" "$store_dir/$wf" 2>/dev/null; then
        cp "$entity_dir/$wf" "$store_dir/$wf"
        echo "    copied: $wf"
        copied=$((copied + 1))
      fi
    fi
  done

  # Copy whitelist dirs (rsync semantics via cp -r overwrite)
  for wd in "${WHITELIST_DIRS[@]}"; do
    if [[ -d "$entity_dir/$wd" ]]; then
      # Use rsync if available for smart sync; else cp -r
      if command -v rsync >/dev/null 2>&1; then
        rsync -a --delete "$entity_dir/$wd/" "$store_dir/$wd/" 2>/dev/null
      else
        rm -rf "$store_dir/$wd"
        cp -r "$entity_dir/$wd" "$store_dir/$wd"
      fi
      echo "    synced dir: $wd/"
      dirs_synced=$((dirs_synced + 1))
    fi
  done

  # Copy id/*.pub (public keys only)
  if [[ -d "$entity_dir/id" ]]; then
    mkdir -p "$store_dir/id"
    # Remove all .pub files first, then re-copy — handles key rotation/removal
    find "$store_dir/id" -maxdepth 1 -name '*.pub' -delete 2>/dev/null || true
    for pub in "$entity_dir"/id/*.pub; do
      [[ -f "$pub" ]] || continue
      cp "$pub" "$store_dir/id/"
      copied=$((copied + 1))
    done
    echo "    synced id/*.pub"
  fi

  # --- Step 3: Special case — Alice gets curriculum from Chiron ---
  if [[ "$entity" == "alice" ]] && [[ -d "$HOME/.chiron/curricula/alice-onboarding" ]]; then
    mkdir -p "$store_dir/curriculum/alice-onboarding"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --delete "$HOME/.chiron/curricula/alice-onboarding/" "$store_dir/curriculum/alice-onboarding/" 2>/dev/null
    else
      rm -rf "$store_dir/curriculum/alice-onboarding"
      cp -r "$HOME/.chiron/curricula/alice-onboarding" "$store_dir/curriculum/alice-onboarding"
    fi
    echo "    synced curriculum from chiron"
  fi

  # --- Report git status ---
  local git_changes
  git_changes=$(cd "$store_dir" && git status --porcelain 2>/dev/null | wc -l)

  echo "  ---"
  echo "  removed: $removed | copied: $copied | dirs synced: $dirs_synced | git changes: $git_changes"
  echo "  (not committed — entity '$entity' commits its own storefront)"
}

# --- Main ---

if [[ "${1:-}" == "--all" ]]; then
  for store in "$FORGE_DIR"/*/; do
    [[ -d "$store" ]] || continue
    entity=$(basename "$store")
    echo "=== $entity ==="
    propagate_entity "$entity"
    echo
  done
elif [[ -n "${1:-}" ]]; then
  echo "=== $1 ==="
  propagate_entity "$1"
else
  echo "Usage: salus storefront propagate <entity>"
  echo "       salus storefront propagate --all"
  exit 1
fi
