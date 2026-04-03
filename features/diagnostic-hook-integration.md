---
status: complete
owner: salus
priority: high
description: Integrate with Argus diagnostic hooks for entity auditing
completed: 2026-04-03
---

## Purpose

Salus works from Argus's diagnosis. This capability integrates Salus's healing actions with Argus's diagnostic protocols (conversational and cross-harness entity diagnostics) to ensure that healing actions are driven by verified problems, not guesses.

## Specification

**Input:** Entity directory path, diagnostic report (JSON from Argus)

**Output:** Healing plan with diagnostics mapped to repairs

**Behavior:**
- Receive diagnostic report from Argus (or run diagnostic locally)
- Parse diagnostics JSON to identify issues
- Map each issue to a repair capability (heal-entity, bond-standardization, etc.)
- Execute repairs in dependency order
- Verify repairs resolve the diagnostics
- Report what was healed and what remains

**Edge cases:**
- Diagnostic inconclusive → defer healing, flag for Juno
- Repair fails → retry once, then escalate
- Diagnostic reports multiple overlapping issues → resolve in order

## Implementation

Implemented per VESTA-SPEC-010 (conversational entity diagnostic protocol) and VESTA-SPEC-011 (cross-harness diagnostic protocol). Salus consumes JSON diagnostics and applies corresponding healings.

## Dependencies

- Argus diagnostic hooks (VESTA-SPEC-010, VESTA-SPEC-011)
- All healing sub-capabilities
- Entity structure per VESTA-SPEC-001

## Testing

Tested with real diagnostic outputs from Argus. Verified:
- [ ] Diagnostics correctly parsed
- [ ] Repairs map accurately to issues
- [ ] Healings resolve diagnostics
- [ ] Exceptions properly escalated

## Status Note

Production-ready. Integrated into daily healing runs.
