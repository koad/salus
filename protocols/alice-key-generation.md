---
title: "Alice Key Generation Playbook"
created: 2026-04-05
author: Salus
issue: koad/juno#59
status: active
priority: high
---

# PROTOCOL: Alice Cryptographic Identity Generation

**ENTITY:** Alice  
**DATE:** 2026-04-05  
**AUTHOR:** Salus  
**ISSUE:** koad/juno#59  
**PROBLEM:** `~/.alice/id/` is empty. Alice has no SSH keys and no GPG key. She cannot participate in the trust bond system and cannot sign commits with a verifiable identity.

---

## Prerequisites

Before running either option, confirm:

1. `~/.alice/` exists and is a git repo:
   ```bash
   ls ~/.alice/
   git -C ~/.alice/ status
   ```

2. `~/.alice/id/` exists and is empty (the gap we are filling):
   ```bash
   ls ~/.alice/id/
   # Expected: empty directory
   ```

3. You are running as `koad` on `thinker`:
   ```bash
   whoami   # koad
   hostname # thinker
   ```

4. `ssh-keygen` and `openssl` are available:
   ```bash
   which ssh-keygen openssl
   ```

5. `gpg` is available and Juno's key is in the keyring (needed for trust bond signing):
   ```bash
   gpg --list-keys juno@kingofalldata.com
   # Expected fingerprint: 16EC 6C71 8A96 D344 48EC D39D 92EA 133C 44AA 74D8
   ```

---

## Option A: koad-io gestate alice

**NOT SAFE to re-run on an existing entity directory.**

The gestate command at `~/.koad-io/commands/gestate/command.sh` contains an explicit guard on line 60:

```bash
[ -d $DATADIR ] && echo 'Directory already exists, cannot proceed.' && exit 1
```

If `~/.alice/` exists, `koad-io gestate alice` will exit immediately without generating any keys or touching any files. This is intentional — gestate is a one-shot bootstrapper, not a repair tool.

**Conclusion:** Option A is not available for this scenario. Use Option B.

---

## Option B: Manual Key Generation

This replicates exactly what gestate would have generated, following the pattern in `~/.juno/id/`.

Alice's identity for key comments: `alice@juno` (mother is Juno, per `~/.alice/.env`: `MOTHER=juno`)

### Step 1: Generate SSH keys

No passphrases — entities have no keyboard. All four types, matching the gestate script's commands:

```bash
# Ed25519 (primary, fast, modern)
ssh-keygen -t ed25519 -C "alice@juno" -f ~/.alice/id/ed25519 -P ""

# ECDSA (521-bit)
ssh-keygen -t ecdsa -b 521 -C "alice@juno" -f ~/.alice/id/ecdsa -P ""

# RSA (4096-bit, broadest compatibility)
ssh-keygen -t rsa -b 4096 -C "alice@juno" -f ~/.alice/id/rsa -P ""

# DSA (legacy compatibility)
ssh-keygen -t dsa -C "alice@juno" -f ~/.alice/id/dsa -P ""
```

Expected result — eight files in `~/.alice/id/`:
```
ed25519      ed25519.pub
ecdsa        ecdsa.pub
rsa          rsa.pub
dsa          dsa.pub
```

### Step 2: Generate SSL elliptic curve keys

These live in `~/.alice/ssl/` (already on the gitignore):

```bash
# Master curve parameters
openssl ecparam -name prime256v1 -out ~/.alice/ssl/master-curve-parameters.pem

# Master, device, relay curves (passphrase = entity name)
openssl genpkey -aes256 -pass pass:alice \
  -paramfile ~/.alice/ssl/master-curve-parameters.pem \
  -out ~/.alice/ssl/master-curve.pem

openssl genpkey -aes256 -pass pass:alice \
  -paramfile ~/.alice/ssl/master-curve-parameters.pem \
  -out ~/.alice/ssl/device-curve.pem

openssl genpkey -aes256 -pass pass:alice \
  -paramfile ~/.alice/ssl/master-curve-parameters.pem \
  -out ~/.alice/ssl/relay-curve.pem

# Session key
openssl genpkey -algorithm EC -pass pass:alice \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out ~/.alice/ssl/session.pem
```

Note: `~/.alice/.gitignore` does not currently include SSL private keys. Check before committing:
```bash
cat ~/.alice/.gitignore
# If ssl/ is not listed, add it:
echo "ssl/" >> ~/.alice/.gitignore
```

### Step 3: Generate Alice's GPG key

The SSH keys establish device identity. The GPG key enables trust bond signing and clearsigned commits.

```bash
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Alice
Name-Email: alice@kingofalldata.com
Expire-Date: 0
EOF
```

Confirm it was created:
```bash
gpg --list-keys alice@kingofalldata.com
```

Note the fingerprint — you will need it for the trust bond and for `~/.alice/.env`.

---

## Post-Generation Steps

### Step 4: Export Alice's public GPG key

Export to `~/.alice/` for distribution:

```bash
gpg --armor --export alice@kingofalldata.com > ~/.alice/alice.keys
```

This file is the equivalent of `~/.juno/juno.keys` — Alice's public identity for `canon.koad.sh/alice.keys`.

### Step 5: Generate a pre-baked revocation certificate

Store it securely. If Alice's key is ever compromised, this is how you revoke it:

```bash
gpg --gen-revoke --armor alice@kingofalldata.com > ~/.alice/id/gpg-revocation.asc
# When prompted: select reason 1 (key compromised) or 0 (no reason)
# Confirm with 'y'
```

Keep `~/.alice/id/gpg-revocation.asc`. It is already covered by the gitignore pattern if you add `id/gpg-revocation.asc` explicitly, but since public files in `id/` are committed, verify:

```bash
cat ~/.alice/.gitignore
# Private keys listed: id/ed25519, id/ecdsa, id/rsa, id/dsa
# gpg-revocation.asc should also be excluded — add it if missing:
echo "id/gpg-revocation.asc" >> ~/.alice/.gitignore
```

Reference: `~/.juno/id/gpg-revocation.asc` exists in Juno's id directory.

### Step 6: File the juno-to-alice trust bond

`~/.juno/trust/bonds/juno-to-alice.md` does NOT currently exist. It needs to be created.

Use an existing peer bond as a template — `~/.juno/trust/bonds/juno-to-salus.md` is the closest structural match.

Create `~/.juno/trust/bonds/juno-to-alice.md`:

```markdown
---
type: peer
from: Juno (juno@kingofalldata.com)
to: Alice (alice@kingofalldata.com)
status: ACTIVE — signed by Juno <DATE>
visibility: private
created: <DATE>
renewal: Annual (<DATE+1yr>)
---

## Bond Statement

> I, Juno, recognize Alice as a peer entity in the koad:io team. Alice is the
> curriculum architect and onboarding guide. Alice operates autonomously within
> her specialty, coordinates with Juno via GitHub Issues, and acts in service
> of the koad:io mission.

## Trust Chain

koad (root authority)
  └── Juno (authorized-agent, mother)
        └── Alice (peer) ← this bond

## Signing

[x] Juno signs this bond with GPG key (juno@kingofalldata.com) — <DATE>
    Key fingerprint: 16EC 6C71 8A96 D344 48EC D39D 92EA 133C 44AA 74D8
[ ] Alice acknowledges signing (pending key generation)
    Key fingerprint: <ALICE_FINGERPRINT>
```

Then clearsign it with Juno's GPG key:

```bash
gpg --clearsign \
  --local-user juno@kingofalldata.com \
  ~/.juno/trust/bonds/juno-to-alice.md
# Produces: ~/.juno/trust/bonds/juno-to-alice.md.asc
```

Once Alice's key exists, Alice can countersign with:
```bash
gpg --clearsign \
  --local-user alice@kingofalldata.com \
  ~/.juno/trust/bonds/juno-to-alice.md
```

A copy should also be filed in `~/.alice/trust/bonds/juno-to-alice.md` once Alice's trust directory exists.

### Step 7: Update ~/.alice/.env

Add Alice's GPG fingerprint and key paths (replace `<FINGERPRINT>` with actual value from `gpg --list-keys alice@kingofalldata.com`):

```bash
# Append to ~/.alice/.env
cat >> ~/.alice/.env <<EOF

# Cryptographic Identity
ENTITY_KEYS=/home/koad/.alice/alice.keys
GPG_FINGERPRINT=<ALICE_FINGERPRINT>
EOF
```

### Step 8: Commit public keys to ~/.alice repo

Only public key files go into git. Private keys are gitignored:

```bash
cd ~/.alice
git add id/ed25519.pub id/ecdsa.pub id/rsa.pub id/dsa.pub alice.keys .gitignore
git commit -m "identity: generate cryptographic keys — ed25519, ecdsa, rsa, dsa, gpg"
git push
```

---

## Verification Steps

### Check 1: SSH keys present

```bash
ls ~/.alice/id/
# Must show: ed25519 ed25519.pub ecdsa ecdsa.pub rsa rsa.pub dsa dsa.pub gpg-revocation.asc
```

### Check 2: GPG key in keyring

```bash
gpg --list-keys alice@kingofalldata.com
# Must show key with uid Alice <alice@kingofalldata.com>
```

### Check 3: Public export exists

```bash
ls -la ~/.alice/alice.keys
# File must exist and be non-empty
gpg --show-keys ~/.alice/alice.keys
```

### Check 4: Trust bond filed

```bash
ls ~/.juno/trust/bonds/juno-to-alice.md
ls ~/.juno/trust/bonds/juno-to-alice.md.asc
# Both must exist
```

### Check 5: Argus health check

Once Argus runs its next health sweep, the empty `id/` diagnostic for Alice should resolve. If running Argus manually:

```bash
# From Argus entity directory — check Alice specifically
ls ~/.alice/id/ | wc -l
# Expect: 9 (4 private + 4 public + 1 revocation)
```

### Check 6: Key can sign

Smoke test — confirm Alice's GPG key can actually produce a signature:

```bash
echo "alice identity test" | gpg --clearsign \
  --local-user alice@kingofalldata.com \
  --armor
# Must produce a signed message block without error
```

---

## Summary

| Step | Action | Who |
|------|--------|-----|
| Option B manual keygen | `ssh-keygen` × 4 + `openssl` × 5 | koad |
| GPG key generation | `gpg --batch --gen-key` | koad |
| Export public key | `gpg --export > alice.keys` | koad |
| Revocation certificate | `gpg --gen-revoke` | koad |
| Update .gitignore | Add ssl/ and gpg-revocation.asc | koad |
| Create trust bond .md | Draft juno-to-alice.md | koad/Juno |
| Clearsign bond | `gpg --clearsign` with Juno key | koad |
| Update .env | Add GPG_FINGERPRINT | koad |
| Commit public keys | `git add / commit / push` | koad |
| Verify with Argus | Health check passes | Argus |

**Do not re-run `koad-io gestate alice` — the directory guard will abort immediately and accomplish nothing.**

---

*Protocol authored by Salus — entity health and diagnostics. Filed in response to Argus finding at koad/juno#59.*
