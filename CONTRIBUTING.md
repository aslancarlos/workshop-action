# Contributing

Contributions are welcome. Please read this guide before opening a pull request.

## Table of Contents

- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Workflow Stages](#workflow-stages)
- [Pull Request Guidelines](#pull-request-guidelines)

## Development Setup

Requirements:
- Docker
- `git`
- MySQL client (for local stage testing)
- Access to a Conjur Cloud tenant (or run locally with `bin/start.sh`)

Clone the repo:

```bash
git clone https://github.com/aslancarlos/workshop-action.git
cd workshop-action
```

## Making Changes

### Action logic (`entrypoint.sh`)

The entrypoint handles three flows:
1. **JWT authentication** (`authn_id` is set)
2. **API key authentication** (`host_id` + `api_key` are set)
3. **Token file** (`authn_token_file` is set)

After authentication, it retrieves each secret via the Conjur REST API and sets it as a masked environment variable via `GITHUB_ENV`.

Key rules:
- The container runs as root — do not add `USER` directive to the Dockerfile
- Never use YAML `>-` folding for the `secrets:` action input
- The `account` for Conjur Cloud is always `conjur`
- Do not change `cyberark/conjur-action@v3` or `docker://cyberark/conjur-action:*` references — these point to the upstream published action

### Workshop stages (`.github/workflows/main.yml`)

Each stage is a separate job with `needs:` chaining. When adding or editing a stage:
- Keep the comment block above each job explaining what it demonstrates
- Use `actions/checkout@v4` (v3 is deprecated)
- Always end stages with `AutoModality/action-clean@v1.1.0`
- Use `continue-on-error: true` only for intentional failure demonstrations (Stage 5)

## Testing

### Unit tests

```bash
bin/coverage.sh
```

### Local integration test (Conjur OSS)

```bash
cd bin
./start.sh
```

### Local integration test (Conjur Enterprise)

```bash
cd bin
./start.sh -e
```

## Workflow Stages

The pipeline has 7 stages. Do not reorder them — each one builds on the previous conceptually:

| Stage | Job | Teaches |
|-------|-----|---------|
| 1 | `stage-1-jwt-auth` | JWT auth, no stored credentials |
| 2 | `stage-2-multiple-secrets` | Multiple secrets, log masking |
| 3 | `stage-3-database` | DB credentials from Privilege Cloud |
| 4 | `stage-4-before-after` | Risk of hardcoded credentials |
| 5 | `stage-5-least-privilege` | Least privilege enforcement |
| 6 | `stage-6-real-query` | End-to-end with real MySQL query |
| 7 | `stage-7-rotation` | Rotation without pipeline changes |

## Pull Request Guidelines

1. Fork the repository and create a branch from `main`
2. Keep changes focused — one concept per PR
3. Update `CHANGELOG.md` under `[Unreleased]`
4. Ensure the workflow still runs end-to-end before requesting review
5. Do not commit secrets, `.env` files, or access tokens
