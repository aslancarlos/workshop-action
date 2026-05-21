# CLAUDE.md — Workshop Action

## What this project is

A GitHub Actions workshop demonstrating secure secrets delivery using **CyberArk Conjur + Privilege Cloud**. It is based on the open-source `cyberark/conjur-action` and adapted for hands-on training sessions.

The workflow (`main.yml`) contains 11 sequential stages, each teaching a specific concept:

| Stage | Job ID | Concept |
|-------|--------|---------|
| 1 | `stage-1-jwt-auth` | JWT authentication — no stored credentials |
| 2 | `stage-2-multiple-secrets` | Multiple secrets + automatic log masking |
| 3 | `stage-3-database` | Database credentials from Conjur (MySQL) |
| 4 | `stage-4-before-after` | Hardcoded credential failure vs Conjur |
| 5 | `stage-5-least-privilege` | Authorized access succeeds; unauthorized is denied |
| 6 | `stage-6-real-query` | End-to-end: Conjur credentials → real MySQL query |
| 7 | `stage-7-rotation` | Credential rotation without pipeline changes |
| 8a/b/c | `stage-8-promote-dev/staging/prod` | Environment promotion dev→staging→prod with approval gate on prod |
| 9 | `stage-9-ssh-deploy` | SSH deploy using username/password from Conjur via sshpass |
| 10 | `stage-10-docker-registry` | Docker Hub login with username/password from Conjur |
| 11 | `stage-11-audit-trail` | Conjur audit API — every secret access logged |

## Key files

| File | Purpose |
|------|---------|
| `action.yml` | GitHub Action definition — uses local `Dockerfile` |
| `Dockerfile` | Container image built at runtime (runs as root) |
| `entrypoint.sh` | Core logic: JWT auth, secret retrieval, masking |
| `.github/workflows/main.yml` | Workshop pipeline with all 11 stages |
| `github-authn-jwt.yml` | Sample Conjur policy for JWT authenticator |
| `github-app-id.yml` | Sample Conjur policy for app host identity |
| `bin/policy/root.yml` | Combined root policy for local testing |

## Secrets required in GitHub repository

Set these under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `CONJUR_URL` | Conjur Cloud URL, e.g. `https://<tenant>.secretsmgr.cyberark.cloud/api` |
| `CONJUR_SERVICE_ID` | JWT authenticator service ID, e.g. `github` |
| `DB_ADDRESS_PLAIN` | Database host address used only in Stage 4 hardcoded failure demo |

## Conjur secrets paths used in the workshop

| Path | Used in |
|------|---------|
| `data/vault/dev-demo-aslan/asramos_pcloud_pov/username` | Stages 1, 2, 5, 8a, 8b |
| `data/vault/dev-demo-aslan/asramos_pcloud_pov/password` | Stages 2, 8a, 8b |
| `data/vault/dev-demo-aslan/dbuser_dual/username` | Stages 3, 4, 6, 7, 8c |
| `data/vault/dev-demo-aslan/dbuser_dual/password` | Stages 3, 4, 6, 7, 8c |
| `data/vault/dev-demo-aslan/dbuser_dual/address` | Stages 3, 4, 6, 7 |
| `data/vault/dev-demo-aslan/jumpserver/username` | Stage 9 (SSH deploy) |
| `data/vault/dev-demo-aslan/jumpserver/password` | Stage 9 (SSH deploy) |
| `data/vault/dev-demo-aslan/jumpserver/address` | Stage 9 (SSH deploy) |
| `data/vault/devsecops/dockerhub_aslan/username` | Stage 10 (Docker Hub login) |
| `data/vault/devsecops/dockerhub_aslan/password` | Stage 10 (Docker Hub login) |

## Important rules when editing this repo

- **Do NOT change** references to `cyberark/conjur-action@v3` or `docker://cyberark/conjur-action:*` — these point to the upstream published action/image and must stay as-is.
- The `action.yml` image is set to `Dockerfile` (local build) — do not change to a DockerHub reference.
- The container runs as **root** (no `USER` directive) to allow writing to `GITHUB_ENV` on self-hosted runners.
- Secrets in the `secrets:` input use `;` as delimiter and `|` to map to env var names. **Never use YAML multi-line folding (`>-`)** for the secrets string — it inserts spaces that break path parsing.
- The `account` field in all workflow steps is hardcoded to `conjur` (correct for Conjur Cloud).

## Running tests locally

```bash
cd bin
./start.sh          # OSS (default)
./start.sh -e       # Enterprise
./start.sh -c       # Cloud (requires INFRAPOOL env vars)
```

Coverage:
```bash
bin/coverage.sh
```

## Conjur host annotation requirements

The GitHub Actions JWT host in Conjur must have both:
```yaml
annotations:
  authn-jwt/github/repository: aslancarlos/workshop-action
  authn-jwt/github/workflow: workshop-action
```

## Common errors

| Error | Cause | Fix |
|-------|-------|-----|
| `CONJ00057E Role does not have the required constraints` | Missing `workflow` annotation on host | Add `authn-jwt/github/workflow` annotation |
| `Malformed authorization token` | Empty token returned from auth | Check `authn_id` and host annotations match |
| `Variable is empty or not found` | Leading space in secret path | Never use YAML `>-` folding for `secrets:` input |
| `Permission denied: set_env_*` | Container UID ≠ runner UID | Container must run as root (no `USER 1001`) |
