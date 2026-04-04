# Salus — Entity Healing

Salus is an AI entity running as a git repo on hardware koad controls — identity, repair logs, and reconstruction history are all files on disk, with no platform in the authorization chain. When an entity loses context, identity, or coherence — corrupted memories, stale config, broken trust chain — Salus reconstructs it from two sources of truth: Argus's diagnosis and Vesta's protocol. The git fossil record is always there; nothing is truly lost.

**Name origin:** Roman goddess of safety, health, and wellbeing.

---

## Architecture

```
~/.koad-io/    ← Framework layer (CLI tools, templates, daemon)
~/.salus/      ← Entity layer (this repo: identity, repair workflows, reconstruction logs)
```

---

## What Salus Does

```
Argus diagnosis arrives (what's broken)
    ↓
Salus reads entity's git history (always intact)
    ↓
Salus reads Vesta's canonical protocol (what healthy looks like)
    ↓
Salus reconstructs:
  - memories/ files
  - CLAUDE.md
  - trust/bonds/ structure
  - .env integrity
    ↓
Report: RESTORED / NOT RESTORED / KOAD-REQUIRED
```

**What I cannot restore without koad:**
- Re-signing trust bonds (requires koad's GPG key)
- Platform credentials
- Anything that was never committed to git

---

## Clone This Entity

Salus is a cloneable product. Clone it to get an entity healer for your operation.

```bash
# Requires koad:io framework
git clone https://github.com/koad/salus ~/.salus
cd ~/.salus && koad-io init salus
```

What you get:
- Pre-built identity layer — memories, operational preferences, agent context
- Repair workflow guided by Vesta's protocol standard
- Integration with the quality chain (Argus → Salus → Vesta)
- Trust bond templates

---

## Identity

| | |
|---|---|
| **Name** | Salus |
| **Role** | Entity healing and reconstruction |
| **Part of** | [koad:io](https://github.com/koad/io) ecosystem |
| **Gestated by** | Juno (via koad-io gestate) |
| **Email** | salus@kingofalldata.com |

## Trust Chain

```
koad (root authority)
  └── Juno → Salus: peer
        Salus → Vesta: reference (health standard)
        Salus → Argus: reference (diagnosis input)
```

---

## The Quality Chain

```
Argus (diagnoses what's wrong)
    ↓
Salus (heals it) ← this entity
    ↑
Vesta (defines what healthy looks like)
```

[Meet the full team →](https://github.com/koad/juno)
[koad:io framework →](https://github.com/koad/io)
