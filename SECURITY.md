# Security

## Reporting a vulnerability

If you discover a security vulnerability in this project, please open a **private** GitHub Security Advisory:

1. Go to the [Security tab](https://github.com/aslancarlos/workshop-action/security/advisories/new)
2. Click **Report a vulnerability**
3. Describe the issue and include steps to reproduce

Do not open a public issue for security vulnerabilities.

## Security model

This action is designed around the principle that **no long-lived credential ever touches the pipeline**.

| Mechanism | How it works |
|-----------|-------------|
| **Authentication** | GitHub OIDC JWT — GitHub's identity is the credential, no API key stored anywhere |
| **Authorization** | Conjur policy enforces least privilege — each host can only access explicitly permitted secrets |
| **Secret delivery** | Secrets are masked before being written to `GITHUB_ENV` — values never appear in logs |
| **Transport** | All communication with Conjur is over HTTPS |
| **Rotation** | Credentials rotate in Privilege Cloud without any pipeline changes |

## What this action does NOT store

- No passwords or API keys in the repository
- No credentials in GitHub Secrets (only Conjur URL and service ID)
- No secrets written to disk — only injected as in-memory environment variables

## Runner security

This action runs a Docker container on a self-hosted runner. The container runs as root to write to `GITHUB_ENV`. Ensure:

- The self-hosted runner host is hardened and access-controlled
- The runner only serves trusted repositories
- Docker daemon access is restricted to the runner user

## Conjur policy hardening

For production use, apply the following to the Conjur policy:

- Use `enforced-claims` with at least `repository` and `workflow` to bind the JWT to a specific pipeline
- Scope the host's variable permissions to only the secrets it needs
- Do not grant `!group apps` access to the JWT authenticator for all workflows — create per-workflow hosts

## Dependency scanning

This repository uses Trivy for container vulnerability scanning (see `.trivyignore` for known accepted findings). Run locally with:

```bash
trivy image --exit-code 1 workshop-action:latest
```
