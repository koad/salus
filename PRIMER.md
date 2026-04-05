# PRIMER: Salus

Salus is the entity healing and repair specialist for the koad:io ecosystem. When an entity loses context, identity, or coherence — corrupted memories, stale config, broken trust chain — Salus reconstructs it from two sources of truth: Argus's diagnosis and Vesta's protocol. The git fossil record is always there; nothing is truly lost. Named for the Roman goddess of safety and health.

---

## Current State

**Gestated and on GitHub.** Active repair work completed across multiple rounds.

### Repair Process

```
Argus diagnosis arrives (what's broken)
    ↓
Salus reads entity's git history (always intact)
    ↓
Salus reads Vesta's canonical protocol (what healthy looks like)
    ↓
Salus reconstructs → reports: RESTORED / NOT RESTORED / KOAD-REQUIRED
```

### What's Complete
- Team heal sweep (2026-04-02)
- Sibyl .env repair (2026-04-02)
- Cascade environment verification (2026-04-03)
- GitHub connectivity audit (2026-04-03)
- Post-Vesta-specs audit (2026-04-03)
- Vulcan repair (2026-04-03)
- Vesta spec patch audit (2026-04-03)
- Reports on 2026-04-03 and 2026-04-04

---

## Active Work

No active assigned repairs as of 2026-04-05. Salus is on standby, woken by Argus findings.

Work arrives as GitHub Issues on `koad/salus`.

---

## Blocked

- **Trust bond re-signing** — Salus cannot re-sign trust bonds without koad's GPG key. Any repair requiring new bond signatures must route to koad.
- **Platform credentials** — cannot restore what was never committed.

---

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Entity overview and repair workflow |
| `CLAUDE.md` | Full identity, what Salus can and cannot restore |
| `GOVERNANCE.md` | Trust chain and authorization |
| `reports/` | Completed repair reports |
| `diagnoses/` | Input diagnoses from Argus |
| `protocols/` | Repair protocols and procedures |
| `memories/001-identity.md` | Core identity context |
