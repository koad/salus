---
status: draft
owner: salus
priority: medium
description: Audit JSONC configuration files for syntax and structure validity
---

## Purpose

Entities may use JSONC (JSON with Comments) files for configuration. Salus should be able to audit these files for syntax errors, schema conformance, and consistency with entity expectations.

## Specification

**Input:** Entity directory path, optional schema file

**Output:** JSONC audit report with syntax and schema validation

**Behavior:**
- Find all `.jsonc` files in entity directory
- Parse each file, reporting syntax errors
- If schema provided:
  - Validate against schema
  - Flag missing required fields
  - Flag unexpected fields
- Check file permissions and ownership
- Report overall conformance

**Edge cases:**
- JSONC syntax invalid → report error location
- Schema missing → audit structure only
- File permission issues → flag

## Implementation

(Not yet built)

## Dependencies

- JSONC parser library
- Optional schema validation (e.g., JSON Schema)
- Entity directory structure

## Testing

Acceptance criteria for completion:
- [ ] Correctly parses JSONC files
- [ ] Detects syntax errors
- [ ] Validates against schema if provided
- [ ] Reports file permissions correctly
- [ ] Tested on entity config files

## Status Note

Draft. Requires decision on JSONC parser and schema validation approach. Blocked on prioritization — may be lower priority than other audits.
