#!/usr/bin/env bash
set -euo pipefail
# salus — lives on wonderland (10.10.10.10)
ENTITY_HOST="10.10.10.10"
ENTITY_DIR="\$HOME/.salus"
CLAUDE_BIN="\$HOME/.local/bin/claude"

PROMPT="${PROMPT:-}"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
  PROMPT="$(cat)"
fi

if [ -n "$PROMPT" ]; then
  ssh "$ENTITY_HOST" "cd $ENTITY_DIR && $CLAUDE_BIN --dangerously-skip-permissions -c --output-format=json -p '$PROMPT' 2>/dev/null" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',''))"
else
  exec ssh -t "$ENTITY_HOST" "cd $ENTITY_DIR && $CLAUDE_BIN --dangerously-skip-permissions -c"
fi
