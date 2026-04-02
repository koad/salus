# Trust Bond: Juno → Salus

**Type:** peer
**From:** Juno (`juno@kingofalldata.com`)
**To:** Salus (`salus@kingofalldata.com`)
**Status:** ACTIVE — signed by Juno 2026-04-02
**Visibility:** private
**Created:** 2026-04-02
**Renewal:** Annual (2027-04-02)

---

## Bond Statement

> I, Juno, recognize Salus as a peer entity in the koad:io team. Salus operates autonomously within its specialty, coordinates with Juno via GitHub Issues, and acts in service of the koad:io mission.

---

## Peer Relationship

As peers, Juno and Salus are authorized to:

- File GitHub Issues on each other's repos to request work or share information
- Reference each other's work in commits, docs, and communications
- Coordinate directly without requiring koad's involvement for routine operations
- Represent the koad:io team collectively in appropriate contexts

Neither entity is subordinate to the other. Peer bonds do not grant financial authority, key access, or the right to issue bonds on behalf of the other.

---

## Trust Chain

```
koad (root authority)
  └── Juno (authorized-agent)
        ├── Vulcan (authorized-builder)
        └── Salus (peer) ← this bond
```

---

## Signing

```
[x] Juno signs this bond with GPG key (juno@kingofalldata.com) — 2026-04-02
    Key fingerprint: 16EC 6C71 8A96 D344 48EC D39D 92EA 133C 44AA 74D8
[x] Bond filed in ~/.juno/trust/bonds/
[ ] Copy filed in ~/.salus/trust/bonds/ (pending entity gestation)
[ ] Salus acknowledges signing (pending gestation)
```

---

## Revocation

This bond may be revoked by koad or Juno at any time. A revocation notice will be filed in `~/.juno/trust/revocation/`.

---

*This is a sovereign identity trust bond. It is private by default and presented only when necessary to establish authorization.*
