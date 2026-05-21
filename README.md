# Workshop Action — CyberArk Conjur + GitHub Actions

Hands-on workshop demonstrating secure secrets delivery to GitHub Actions pipelines using **CyberArk Conjur** and **Privilege Cloud**.

No passwords stored in code, in the runner, or in GitHub Secrets — credentials are fetched at runtime via JWT authentication.

---

## Overview

```
GitHub Actions Runner
       │
       │  1. Request JWT token (OIDC)
       ▼
GitHub OIDC Provider ──► JWT Token
       │
       │  2. Authenticate with JWT
       ▼
CyberArk Conjur ──────────────────► Validates JWT claims
       │                             (repository, workflow)
       │  3. Return session token
       ▼
Conjur API ────────────────────────► Retrieve secrets from
       │                             Privilege Cloud vault
       │  4. Inject as masked env vars
       ▼
Your Workflow Steps
```

---

## Workshop Stages

The pipeline in `.github/workflows/main.yml` runs 11 sequential stages:

### Stage 1 — JWT Auth & Secret Retrieval
Conjur authenticates the workflow using GitHub's OIDC JWT. No API keys or passwords are stored anywhere — GitHub's identity is the credential.

### Stage 2 — Multiple Secrets & Masking
Retrieves multiple secrets in a single call. Demonstrates that GitHub Actions automatically masks secret values in all log output.

### Stage 3 — Database Connection
Fetches database credentials (`username`, `password`, `address`) from Privilege Cloud via Conjur and opens a live MySQL connection.

### Stage 4 — Hardcoded vs Conjur (Before/After)
First attempts to connect with a hardcoded password (fails). Then retrieves the current password from Conjur and connects successfully. Makes the risk of hardcoded credentials tangible.

### Stage 5 — Least Privilege / Access Denied
Accesses an authorized secret (succeeds), then attempts to access an unauthorized path (denied). Shows that the Conjur host can only reach what its policy explicitly permits.

### Stage 6 — Real Query & Data Retrieval
Full end-to-end demo: Conjur delivers DB credentials → MySQL query runs → real data returned. No credential ever touches the pipeline code.

### Stage 7 — Credential Rotation
Connects to the database using the current Conjur credentials and prompts the presenter to rotate the password in Privilege Cloud. Re-running the pipeline with zero changes shows the new password works automatically.

### Stage 8 — Environment Promotion (dev → staging → prod)
Three sub-stages chained with `needs:`. Each runs in a different GitHub Environment with its own secrets. The `prod` job pauses and waits for a human reviewer to approve before running — demonstrating governance over production deployments. Requires `staging` and `prod` GitHub Environments to be created under Settings → Environments, with at least one Required Reviewer on `prod`.

### Stage 9 — SSH Deploy with Credentials from Conjur
Retrieves SSH credentials (`username`, `password`, `address`) from the `jumpserver` account in Privilege Cloud and connects to the remote server using `sshpass`. No credentials are stored in the repo or in GitHub Secrets.

### Stage 10 — Docker Registry Login with Conjur Credentials
Fetches Docker Hub `username` and `password` from the `dockerhub_aslan` account in Privilege Cloud via Conjur, performs `docker login docker.io` with `--password-stdin` (no credential in the command line), and logs out. Demonstrates credential injection into container workflows.

### Stage 11 — Audit Trail
Authenticates with Conjur directly via the JWT and calls the Conjur audit API to retrieve the last 20 secret fetch events. Displays who accessed what and when — showing the full traceability that Conjur provides for compliance and incident response.

---

## Prerequisites

- CyberArk Conjur Cloud tenant
- CyberArk Privilege Cloud with at least two safes/accounts configured
- GitHub self-hosted runner with Docker and MySQL client installed
- GitHub repository with Actions enabled

---

## Setup

### 1. Configure the Conjur JWT Authenticator

Load the JWT authenticator policy (`github-authn-jwt.yml`):

```bash
conjur policy load -f github-authn-jwt.yml -b root
```

Set the authenticator variables:

```bash
conjur variable set -i conjur/authn-jwt/github/issuer \
  -v "https://token.actions.githubusercontent.com"

conjur variable set -i conjur/authn-jwt/github/jwks-uri \
  -v "https://token.actions.githubusercontent.com/.well-known/jwks"

conjur variable set -i conjur/authn-jwt/github/token-app-property \
  -v "workflow"

conjur variable set -i conjur/authn-jwt/github/identity-path \
  -v "/github-apps"

conjur variable set -i conjur/authn-jwt/github/enforced-claims \
  -v "workflow,repository"
```

### 2. Create the GitHub App Host

Load the app identity policy (`github-app-id.yml`):

```bash
conjur policy load -f github-app-id.yml -b root
```

The host must have both annotations:

```yaml
annotations:
  authn-jwt/github/repository: aslancarlos/workshop-action
  authn-jwt/github/workflow: workshop-action
```

### 3. Configure GitHub Repository Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|--------|-------|
| `CONJUR_URL` | `https://<tenant>.secretsmgr.cyberark.cloud/api` |
| `CONJUR_SERVICE_ID` | JWT authenticator ID (e.g. `github`) |
| `DB_ADDRESS_PLAIN` | Database host address — used only in Stage 4 hardcoded failure demo |

### 4. Ensure the Self-Hosted Runner Has Required Tools

```bash
# Ubuntu / Debian
sudo apt-get install -y mysql-client sshpass

# RHEL / Amazon Linux
sudo yum install -y mysql sshpass
```

---

## Action Usage

To use this action in your own workflow:

```yaml
- name: Retrieve secrets from Conjur
  uses: aslancarlos/workshop-action@main
  with:
    url: ${{ secrets.CONJUR_URL }}
    account: conjur
    authn_id: ${{ secrets.CONJUR_SERVICE_ID }}
    secrets: "path/to/secret|ENV_VAR_NAME;path/to/other/secret|OTHER_VAR"
```

### Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `url` | Yes | Conjur endpoint URL |
| `account` | Yes | Conjur account name (usually `conjur` for Cloud) |
| `authn_id` | No | JWT authenticator service ID |
| `host_id` | No | Host ID for API key authentication |
| `api_key` | No | API key for host authentication |
| `secrets` | Yes | Semicolon-delimited list of secrets to retrieve |
| `certificate` | No | Self-signed SSL certificate content |
| `audience` | No | Custom `aud` claim value for JWT |
| `authn_token_file` | No | Path to a pre-fetched Conjur auth token |

### Secrets Syntax

```
path/to/variable|ENV_VAR_NAME;path/to/other/variable
```

- Delimiter: `;` between secrets
- Mapping: `|` separates the Conjur variable path from the environment variable name
- If no name is given, the last segment of the path is used (uppercased)

**Important:** never use YAML multi-line folding (`>-`) for the `secrets` input. It inserts spaces that break path parsing.

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `CONJ00057E Role does not have the required constraints` | Missing `workflow` annotation on host | Add `authn-jwt/github/workflow: workshop-action` to the host |
| `Malformed authorization token` | Auth returned empty token | Verify `CONJUR_SERVICE_ID` and host annotations match |
| `Variable is empty or not found` | Space in secret path | Remove YAML `>-` folding from `secrets:` input |
| `Permission denied: set_env_*` | Container running as non-root user | Dockerfile must not set `USER 1001` |
| `Node.js 20 actions are deprecated` | Outdated `actions/checkout` version | Use `actions/checkout@v4` |

---

## Architecture

```
.
├── action.yml                    # Action definition (uses local Dockerfile)
├── Dockerfile                    # Container image (Alpine, runs as root)
├── entrypoint.sh                 # JWT auth + secret retrieval logic
├── .github/
│   └── workflows/
│       └── main.yml              # 11-stage workshop pipeline
├── github-authn-jwt.yml          # Sample: JWT authenticator Conjur policy
├── github-app-id.yml             # Sample: app host identity Conjur policy
└── bin/
    ├── policy/root.yml           # Combined policy for local dev
    ├── start.sh                  # Start local test environment
    ├── stop.sh                   # Stop local test environment
    └── coverage.sh               # Run test coverage
```

---

## Security

- Secrets are never logged — they are masked before being set as environment variables
- JWT authentication uses GitHub's OIDC provider — no long-lived credentials needed
- The Conjur host policy enforces least privilege — each workflow only accesses its permitted secrets
- See [SECURITY.md](SECURITY.md) for vulnerability reporting

---

## License

[MIT](LICENSE)
