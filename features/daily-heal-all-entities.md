---
status: complete
owner: salus
priority: critical
description: Run daily health checks and healing on all 12 koad:io entities
completed: 2026-04-03
---

## Purpose

Salus's core responsibility: every day, check all 12 entities in the koad:io ecosystem and heal any issues that can be fixed automatically. This is the master healing orchestration.

## Specification

**Input:** None (daily trigger)

**Output:** Consolidated healing report for all entities, filed to `~/.salus/reports/YYYY-MM-DD.md`

**Behavior:**
- Iterate through all 12 entities in order: juno, vulcan, veritas, mercury, muse, sibyl, argus, janus, salus (self), aegis, vesta, iris
- For each entity:
  - Run heal-entity (create missing files/dirs)
  - Check git stall (flagged if > 14 days)
  - Validate daemon health
  - Standardize bonds
  - Verify environment conformance
- Collect all issues into structured report
- Commit daily report to ~/.salus/reports/
- Push report to GitHub
- File critical issues as GitHub issues on koad/juno

**Edge cases:**
- Entity stalled > 14 days → flag critical
- GitHub push fails → note but continue
- Multiple issues on one entity → aggregate in report

## Implementation

Implemented as core daily healing protocol in `memories/004-healing-protocol.md`. Invoked via: `PROMPT="run daily heal on all entities" salus`

## Dependencies

- All healing sub-capabilities (heal-entity, git-stall-detection, daemon-health-check, etc.)
- VESTA-SPEC-001 (entity model)
- Argus diagnostic capabilities

## Testing

Tested daily for 10+ days. Verified:
- [ ] All 12 entities processed each run
- [ ] Reports generated consistently
- [ ] Critical issues flagged correctly
- [ ] GitHub issues filed appropriately
- [ ] No entity left unhealed

## Status Note

Production-ready. Runs daily as part of Salus's core mandate.
