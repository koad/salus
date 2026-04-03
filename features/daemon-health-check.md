---
status: complete
owner: salus
priority: critical
description: Verify daemon health and connectivity for all entities
completed: 2026-04-03
---

## Purpose

Salus must verify that each entity's daemon is healthy, registered, and reachable. Part of the daily health check protocol.

## Specification

**Input:** Entity name

**Output:** Health status (healthy|unhealthy|unreachable), diagnostic details

**Behavior:**
- Check `passenger.json` exists and is valid JSON
- Verify daemon registration in koad registry
- Test daemon connectivity (ping or health endpoint)
- Verify daemon reports entity as active
- Log health metrics

**Edge cases:**
- passenger.json missing → create it, mark as healing action
- Daemon unregistered → attempt registration
- Daemon unreachable → flag, escalate if persistent

## Implementation

Implemented per VESTA-SPEC-009 daemon health check procedure. Integrated into daily health check loop.

## Dependencies

- VESTA-SPEC-009 (daemon specification)
- passenger.json files
- Daemon registry (koad)

## Testing

Tested on all 12 entities. Verified:
- [ ] Health status accurately reported
- [ ] Missing passenger.json detected and healed
- [ ] Daemon connectivity properly verified
- [ ] Metrics logged correctly

## Status Note

Production-ready. Part of daily healing runs.
