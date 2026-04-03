---
status: complete
owner: salus
priority: high
description: Detect when entities have been inactive for > 14 days
completed: 2026-04-03
---

## Purpose

Identify entities that have not been updated in over 14 days, indicating possible stall. This is flagged to Juno for review — an entity that hasn't changed in 2+ weeks may need intervention or deactivation.

## Specification

**Input:** Entity directory path

**Output:** Stall status (active|stalled|critical), days since last commit

**Behavior:**
- Check entity's git log for most recent commit
- Calculate days since last activity
- Mark as:
  - `active` if < 7 days
  - `stalled` if 7-14 days
  - `critical` if > 14 days
- Log findings with commit hash and date

**Edge cases:**
- No git history → treat as critical (entity broken)
- Local commits not pushed → still count as active

## Implementation

Implemented in daily healing protocol. Uses `git log --oneline -1` to get last commit timestamp.

## Dependencies

- Entity git history
- Daily healing loop iteration

## Testing

Tested on all 12 entities. Verified:
- [ ] Stall detection accurate
- [ ] Days calculation correct
- [ ] Critical cases identified
- [ ] Flagging to Juno working

## Status Note

Production-ready. Integrated into daily healing runs.
