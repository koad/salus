---
status: in-progress
owner: salus
priority: high
description: Create and validate passenger.json daemon registration files
started: 2026-03-25
---

## Purpose

Each entity must have a `passenger.json` file that registers it with the koad daemon. Salus must be able to create valid passenger.json from entity `.env` and validate existing ones for correctness and consistency.

## Specification

**Input:** Entity directory path, entity `.env` file

**Output:** passenger.json file (created or validated), validation report

**Behavior:**
- Parse entity `.env` to extract ENTITY, GIT_AUTHOR_NAME, GIT_AUTHOR_EMAIL
- Generate passenger.json with required structure:
  - `handle`: from ENTITY variable
  - `author`: from GIT_AUTHOR_NAME
  - `email`: from GIT_AUTHOR_EMAIL
  - `created`: current timestamp
  - `version`: daemon API version
- Validate JSON schema
- Check that handle matches directory name
- Verify all required fields present

**Edge cases:**
- ENTITY variable missing from .env → escalate (entity broken)
- passenger.json exists but is malformed → repair
- Mismatch between handle and directory name → flag for investigation

## Implementation

(In development)

## Dependencies

- Entity .env files
- VESTA-SPEC-001 (entity model, passenger.json structure)
- VESTA-SPEC-009 (daemon specification)

## Testing

Acceptance criteria for completion:
- [ ] Can create valid passenger.json from .env
- [ ] Validates schema correctly
- [ ] Detects malformed files
- [ ] Tested on all 12 entities
- [ ] JSON parses correctly by daemon

## Status Note

In-progress. Core creation logic drafted. Validation logic pending. Need to verify daemon expects.
