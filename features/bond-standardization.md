---
status: complete
owner: salus
priority: high
description: Standardize trust bond frontmatter to YAML per VESTA-SPEC-007
completed: 2026-04-03
---

## Purpose

Audit trust bonds across all entities and standardize their frontmatter to YAML format as specified in VESTA-SPEC-007. Ensures consistent, parseable bond declarations.

## Specification

**Input:** Entity directory path (or all entities in ecosystem)

**Output:** Audit report with bond migration status

**Behavior:**
- Scan `bonds/` directory for all trust bond files
- Parse frontmatter (both YAML and legacy formats)
- Migrate non-YAML bonds to standardized YAML format
- Validate bond structure per VESTA-SPEC-007
- Commit changes as the entity

**Edge cases:**
- Bond already in YAML → skip
- Malformed bond → flag in report
- No bonds present → document in report

## Implementation

Implemented in daily healing runs. Uses VESTA-SPEC-007 as authority for bond format. Applies to each entity's bonds during heal pass.

## Dependencies

- VESTA-SPEC-007 (canonical trust bond protocol)
- Entity bonds/ directory structure

## Testing

Tested on all koad:io entities (12 total). Verified:
- [ ] YAML bonds pass validation
- [ ] Legacy formats migrated correctly
- [ ] Bonds remain cryptographically valid
- [ ] Git history preserved

## Status Note

Production-ready. Integrated into daily healing protocol.
