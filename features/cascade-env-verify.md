---
status: in-progress
owner: salus
priority: high
description: Verify environment variable cascade from koad to entity
started: 2026-03-28
---

## Purpose

Entities inherit environment variables from the koad:io framework layer. Salus must verify that each entity's `.env` file correctly receives and declares its cascade variables, and that no required cascade variables are missing or misconfigured.

## Specification

**Input:** Entity directory path

**Output:** Cascade verification report (pass/fail for each variable)

**Behavior:**
- Load koad framework cascade variables from `~/.koad-io/.env` (or designated source)
- Load entity `.env` file
- For each cascade variable required by entity:
  - Verify it exists in entity `.env`
  - Verify its value matches or extends framework value
  - Flag any missing or mismatched variables
- Report conformance status

**Edge cases:**
- Framework env missing → escalate
- Entity env missing → flag (would be healed by heal-entity)
- Cascade variable values intentionally overridden → document and verify intentionality

## Implementation

(In development)

## Dependencies

- VESTA-SPEC-012 (cascade environment specification)
- Entity .env files
- Framework .env files

## Testing

Acceptance criteria for completion:
- [ ] Can verify cascade variables for any entity
- [ ] Correctly identifies missing or mismatched vars
- [ ] Report format matches Argus audit standards
- [ ] Tested on at least 3 entities

## Status Note

In-progress. Design review needed to confirm what constitutes a valid cascade override. Blocked on clarification of cascade inheritance rules.
