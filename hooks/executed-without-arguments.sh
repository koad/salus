#!/usr/bin/env bash
set -euo pipefail
# Salus — interactive or prompt-driven
# Usage: salus                               → interactive Claude Code session
#        PROMPT="heal ~/.veritas" salus      → non-interactive, identity + prompt
#        echo "heal ~/.veritas" | salus      → non-interactive, stdin

IDENTITY="$HOME/.salus/memories/001-identity.md"

PROMPT="${PROMPT:-}"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
  PROMPT="$(cat)"
fi

cd "$HOME/.salus"

if [ -n "$PROMPT" ]; then
  exec claude -p "$(cat "$IDENTITY")

$PROMPT"
else
  exec claude . --model sonnet
fi
