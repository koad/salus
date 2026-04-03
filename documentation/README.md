# Salus Documentation

Salus is the healer of the koad:io ecosystem. This directory contains documentation about Salus's capabilities, architecture, and healing protocols.

## What is Salus?

Salus (Roman goddess of safety and wellbeing) is an autonomous entity that:
- Runs daily health checks on all 12 koad:io entities
- Automatically fixes common issues (missing files, broken hooks, stalled entities)
- Escalates problems to Juno that require human decision-making
- Reports healing results daily to `~/.salus/reports/YYYY-MM-DD.md`

## Core Files

- **CLAUDE.md** — Salus's self-knowledge and behavioral constraints
- **memories/001-identity.md** — Core identity declaration
- **memories/004-healing-protocol.md** — Daily healing protocol specification
- **reports/** — Daily healing reports

## Features

Salus's capabilities are documented in `~/.salus/features/`:

### Complete Features
- **heal-entity** — Repair missing directories, files, and hooks
- **bond-standardization** — Standardize trust bonds to YAML
- **daemon-health-check** — Verify daemon health for all entities
- **daily-heal-all-entities** — Master healing orchestration (12 entities)
- **diagnostic-hook-integration** — Integrate with Argus diagnostics
- **git-stall-detection** — Detect inactive entities (>14 days)

### In-Progress Features
- **cascade-env-verify** — Verify environment variable inheritance
- **passenger-json-validation** — Create and validate daemon registration
- **env-identity-audit** — Audit entity .env for consistency

### Draft Features
- **opencode-jsonc-audit** — Audit JSONC configuration files

See `~/.salus/features/` for full specifications of each capability.

## Daily Healing Run

Salus runs daily via:
```bash
PROMPT="run daily heal on all entities" salus
```

This iterates through all 12 entities in order:
```
juno → vulcan → veritas → mercury → muse → sibyl → argus → janus → salus → aegis → vesta → iris
```

For each entity, Salus:
1. Heals missing files and directories
2. Detects git stalls (> 14 days)
3. Checks daemon health
4. Standardizes trust bonds
5. Verifies environment conformance

Results are committed to `~/.salus/reports/YYYY-MM-DD.md` and pushed to GitHub.

## Position in the Ecosystem

```
koad (root authority)
  └── Juno (orchestrator)
        ├── Argus (diagnoses problems) → Salus input
        ├── Salus (heals problems)     ← this is me
        └── Vesta (defines healthy)    → Salus authority
```

- **Argus** tells Salus what's broken
- **Vesta** tells Salus what healthy looks like
- **Juno** makes business decisions about escalations

## Healing Philosophy

Salus operates under these constraints:

1. **Heal to spec, not to memory** — Vesta defines healthy, not Salus's interpretation
2. **Don't diagnose** — Argus diagnoses. Salus executes repairs.
3. **Report what couldn't be fixed** — Incomplete healing is escalated to Juno
4. **Preserve git history** — The commit history is the recovery path
5. **No business decisions** — That's Juno's role
6. **No publishing** — That's Mercury's role
7. **No building** — That's Vulcan's role

## Escalation to Juno

Salus escalates to Juno via GitHub issues on `koad/juno` when:
- An entity's identity is missing and must be authored (not generated)
- Entity is stalled > 14 days
- Entity `.env` file is missing entirely (corrupted)
- Healing action fails after retry
- A decision is needed that involves business logic

## Feature Inventory Protocol

Salus uses VESTA-SPEC-013 (Features-as-Deliverables Protocol) to track its own capabilities. See `~/.salus/features/` for:
- Each feature documented as a markdown file
- Frontmatter: `status` (draft|in-progress|complete), `owner`, `priority`, `description`
- Full spec including purpose, behavior, dependencies, and testing criteria

## Communication

- **Receive work:** GitHub issues on `koad/salus` from Juno
- **Report results:** Daily reports committed to `~/.salus/reports/`
- **Escalate:** File issues on `koad/juno` for problems requiring Juno decision
- **Document healing:** Commit messages include entity name and what was healed

## Key Specs

| Spec | Purpose |
|------|---------|
| VESTA-SPEC-001 | Entity model (what Salus heals to) |
| VESTA-SPEC-007 | Trust bond protocol (bonds standardization) |
| VESTA-SPEC-009 | Daemon specification (health checks) |
| VESTA-SPEC-010 | Conversational diagnostic protocol (diagnostic integration) |
| VESTA-SPEC-012 | Cascade environment (env verification) |
| VESTA-SPEC-013 | Features-as-deliverables (this documentation) |

## Questions?

File issues on `koad/salus` or `koad/juno`.
