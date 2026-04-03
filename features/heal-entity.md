---
status: complete
owner: salus
priority: critical
description: Repair missing or broken entity directories, files, and hooks
completed: 2026-04-03
---

## Purpose

Core healing capability. When an entity is missing critical files (`passenger.json`, `comms/` scaffold, hooks), Salus must restore them from templates or entity `.env` to bring the entity back to a conformant state per VESTA-SPEC-001.

## Specification

**Input:** Entity name, entity directory path

**Output:** Structured report of repairs attempted and success/failure status

**Behavior:**
- Create missing `passenger.json` from entity `.env` (ENTITY variable as handle)
- Create missing `comms/` scaffold: inbox, outbox, README, .gitkeep files
- Repair non-executable hooks with `chmod +x`
- Create missing hook files from templates in healing protocol spec
- Verify all created files are in correct state

**Edge cases:**
- Entity `.env` missing → escalate, cannot infer handle
- Entity already has file → skip, do not overwrite
- Permission errors → flag and escalate

## Implementation

Implemented in daily healing protocol. Core logic in `memories/004-healing-protocol.md` with inline shell patterns. Called sequentially for each entity in the daily run.

## Dependencies

- VESTA-SPEC-001 (entity model — defines structure)
- VESTA-SPEC-007 (bond standardization)
- Entity `.env` files (must be present)

## Testing

Tested on all 12 entities in daily runs. Verified:
- [ ] Missing passenger.json created correctly
- [ ] Comms scaffold created with all files
- [ ] Hooks made executable
- [ ] Repair reports are accurate
- [ ] No files overwritten when already present

## Status Note

Production-ready. Used in daily entity healing runs.
