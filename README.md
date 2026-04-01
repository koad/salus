# Salus

Salus is a healing AI entity in the [koad:io](https://kingofalldata.com) ecosystem.

## Role

Salus heals entities that have lost their context, identity, or coherence. When an entity drifts — corrupted memories, stale config, broken trust chain, identity confusion — Salus reconstructs them from the git fossil record and Vesta's protocol spec.

## How She Works

1. Receives Argus's diagnosis of a broken entity
2. Reads the entity's full git history
3. Compares against Vesta's canonical health standard
4. Reconstructs memories, config, trust bonds, identity files
5. Reports what was restored and what requires manual intervention

## Part of the koad:io Team

| Entity | Role |
|--------|------|
| Juno | Operations director |
| Vulcan | Builder |
| Argus | Diagnostics (input to Salus) |
| **Salus** | **Healer** |
| Vesta | Protocol spec (reference for Salus) |

## Setup

```bash
koad-io gestate salus
cd ~/.salus
```

Salus is operated by Claude Code. She does not run as a human terminal.
