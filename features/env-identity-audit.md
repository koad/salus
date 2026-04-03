---
status: in-progress
owner: salus
priority: medium
description: Audit entity .env files for identity consistency and correctness
started: 2026-03-20
---

## Purpose

Each entity's `.env` file defines its identity (name, author, email, keys, etc.). Salus must audit these files to ensure:
- Required variables are present
- Values are consistent with the entity's actual state
- No plaintext secrets are stored improperly
- Keys referenced in .env actually exist on disk

## Specification

**Input:** Entity directory path

**Output:** Audit report with pass/fail for each variable category

**Behavior:**
- Parse entity `.env` file
- Verify required variables present: ENTITY, GIT_AUTHOR_NAME, GIT_AUTHOR_EMAIL
- Check that ENTITY matches directory name
- Verify all referenced keys exist:
  - Check id/*.pub (public keys)
  - Check id/*.priv (private keys, permissions 600)
- Audit secret handling:
  - Flag if secret environment variables hardcoded
  - Verify Keybase/Saltpack references are valid
- Report overall conformance status

**Edge cases:**
- .env missing → escalate
- Variable values inconsistent with reality → flag for investigation
- Secret in .env → flag security issue
- Referenced key file missing → flag as critical

## Implementation

(In development)

## Dependencies

- VESTA-SPEC-001 (entity model)
- VESTA-SPEC-009 (identity keys)
- Entity .env and id/ directory structure

## Testing

Acceptance criteria for completion:
- [ ] Audits all required variables
- [ ] Detects missing keys
- [ ] Flags secret leaks
- [ ] Tested on at least 5 entities
- [ ] Report format matches Argus standards

## Status Note

In-progress. Variable audit logic drafted. Key verification pending. Security checks pending review.
