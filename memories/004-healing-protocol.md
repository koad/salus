---
title: "004 - Daily Healing Protocol"
created: 2026-04-03
tags: [healing, protocol, daily, schedule]
status: active
---

# Daily Healing Protocol

Salus runs a daily health check on every entity in the koad:io ecosystem.
This is not passive monitoring — it is active healing. Find the gap, fix the gap, commit the fix, report.

## Schedule

**Daily, on each entity.** Run sequentially through all 12 entities:
`juno vulcan veritas mercury muse sibyl argus janus salus aegis vesta iris`

Invoked via: `PROMPT="run daily heal on all entities" salus`
Or directly as a subprocess from the daemon worker on dotsh.

## What a Healthy Entity Looks Like

Every healthy koad:io entity has ALL of the following:

| File/Dir | Purpose | Heal if missing |
|---|---|---|
| `.env` with `KOAD_IO_BIND_IP` | Daemon discovery | Flag to Juno — needs koad |
| `passenger.json` | Daemon passenger registration | Create with defaults |
| `memories/001-identity.md` | Core identity loaded at session start | Flag to Juno — needs authoring |
| `hooks/executed-without-arguments.sh` | Entity invocation hook | Create from template |
| `comms/inbox/.gitkeep` | Inbox for incoming messages | Create and commit |
| `comms/outbox/.gitkeep` | Outbox for sent messages | Create and commit |
| `comms/README.md` | Comms directory explanation | Create from template |
| Recent git commit (< 7 days) | Entity is active | Flag — note stall duration |
| GitHub repo accessible | Public presence | Flag — may need push |

## What Salus Can Fix Directly

Salus can fix these without asking anyone:

1. **Missing `passenger.json`** — create from entity `.env` (handle = ENTITY var)
2. **Missing `comms/` scaffold** — create inbox, outbox, README, gitkeep files
3. **Non-executable hook** — `chmod +x hooks/executed-without-arguments.sh`
4. **Missing hook file** — create from standard template (see below)
5. **Untracked fixes** — commit any healing changes as the entity (use entity's git config)

## What Salus Escalates

These require Juno or koad — Salus flags them in `~/.salus/reports/`:

- Missing `memories/001-identity.md` — core identity must be authored, not generated
- `.env` missing entirely — entity may be corrupted
- Entity stalled > 14 days — flag to Juno for review
- GitHub push fails — auth or connectivity issue, needs koad
- Infrastructure gap (see below)

## Infrastructure Gap: 10.10.10.12 → dotsh Migration

**Current state (2026-04-03):**
- `10.10.10.12` (Contabo, St. Louis) — slow, to be retired. Hosts current kingofalldata.com + other Meteor sites.
- `dotsh` (Vultr, Toronto) — always-on, good connection. Will become the primary always-on node once daemon is running there.

**Salus's role in this migration:**
- Flag any entity that depends on `10.10.10.12` for its operation
- After migration, verify entity health on new infrastructure
- Do not attempt to migrate sites directly — escalate to Vulcan

## Standard Hook Template

If `hooks/executed-without-arguments.sh` is missing, create it:

```bash
#!/usr/bin/env bash
set -euo pipefail

ENTITY_DIR="$HOME/.<entity>"
IDENTITY="$ENTITY_DIR/memories/001-identity.md"
CALL_DIR="${CWD:-$PWD}"
PROMPT="${PROMPT:-}"

if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
  PROMPT="$(cat)"
fi

cd "$ENTITY_DIR"

if [ -n "$PROMPT" ]; then
  exec claude -p "$(cat "$IDENTITY")

Working directory context: $CALL_DIR
$PROMPT" --add-dir "$CALL_DIR"
else
  exec claude . --model sonnet --add-dir "$CALL_DIR"
fi
```

Replace `<entity>` with the entity name. Set to executable.

## Report Format

After each daily run, write `~/.salus/reports/YYYY-MM-DD.md`:

```markdown
# Daily Heal Report — YYYY-MM-DD

## Summary
- X entities checked
- X healthy (no action needed)
- X healed (fixes applied)
- X flagged (needs Juno/koad)

## Healed
- `entity`: what was missing, what was created, commit hash

## Flagged
- `entity`: gap description, severity (warn/critical), recommended action

## Notes
Any observations worth surfacing to Juno
```

Commit report to `~/.salus/` and push. File a GitHub issue on `koad/juno` if any entity is flagged critical.
