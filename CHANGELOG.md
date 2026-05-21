# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0] - 2026-05-21

### Added
- 7-stage workshop pipeline demonstrating Conjur + GitHub Actions integration
  - Stage 1: JWT authentication and basic secret retrieval
  - Stage 2: Multiple secrets with automatic log masking
  - Stage 3: MySQL database connection using Privilege Cloud credentials
  - Stage 4: Before/After — hardcoded credential failure vs Conjur
  - Stage 5: Least privilege enforcement (authorized vs unauthorized access)
  - Stage 6: End-to-end real MySQL query with Conjur credentials
  - Stage 7: Credential rotation demo with zero pipeline changes
  - Stage 8: Environment promotion (dev → staging → prod) with approval gate on prod
  - Stage 9: SSH deploy using private key retrieved from Conjur
  - Stage 10: Docker registry login using credentials from Conjur
  - Stage 11: Audit trail — queries Conjur API to show every secret access logged
- `CLAUDE.md` with project context, rules, and troubleshooting for AI-assisted development
- `CONTRIBUTING.md` with development setup and PR guidelines
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `workflow_dispatch` trigger to allow manual pipeline runs

### Changed
- Forked from `cyberark/conjur-action` and renamed to `workshop-action`
- `action.yml` now uses local `Dockerfile` instead of published DockerHub image
- Dockerfile no longer sets `USER 1001` — container runs as root for `GITHUB_ENV` write access
- Upgraded `actions/checkout` from v3 to v4 (Node.js 24 compatible)
- Workflow trigger branch changed from `master` to `main`
- Rewrote `README.md` with full workshop setup guide, architecture diagram, and troubleshooting table
- Updated `SECURITY.md` with security model and runner hardening guidance

### Fixed
- `GITHUB_ENV` permission denied error on self-hosted runners caused by container UID mismatch
- Secret path parsing broken by YAML `>-` folding inserting spaces after semicolons

## [2.1.1] - 2026-03-23

### Fixed
- Fixed support of JWT authenticatiors without token-app-property. 
- Fixed support for custom audience claim.

## [2.1.0] - 2026-01-12

### Changed
- The action is now using a pre-build image hosted on DockerHub in order to enable the usage of kubernetes mode for self-hosted runners
- The image now uses a non-root user

## [2.0.12] - 2025-06-24

### Added
- Fixed the JWT token issue

## [2.0.11] - 2025-06-17

### Added
- Fixed a changelog issue in telemetry header preparation

## [2.0.10] - 2025-06-06

### Added
- Addressed issue in preparing telemetry header

## [2.0.9] - 2025-06-05

### Added
- Fix the telemetry header issue.

## [2.0.8] - 2025-05-30

### Added
- Automated tests for Edge
- Added unit tests.

## [2.0.7] - 2025-03-24

### Added
- Automated tests for OSS, EP, and Cloud
- Telemetry headers integration

## [2.0.6] - 2024-02-16

### Security
- Updated Alpine base image

## [2.0.5] - 2023-04-20

### Added
- Initial release

[Unreleased]: https://github.com/cyberark/conjur-action/compare/v2.1.1...HEAD
[2.1.0]: https://github.com/cyberark/conjur-action/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/cyberark/conjur-action/compare/v2.0.12...v2.1.0
[2.0.12]: https://github.com/cyberark/conjur-action/compare/v2.0.11...v2.0.12
[2.0.11]: https://github.com/cyberark/conjur-action/compare/v2.0.10...v2.0.11
[2.0.10]: https://github.com/cyberark/conjur-action/compare/v2.0.9...v2.0.10
[2.0.9]: https://github.com/cyberark/conjur-action/compare/v2.0.8...v2.0.9
[2.0.8]: https://github.com/cyberark/conjur-action/compare/v2.0.7...v2.0.8
[2.0.7]: https://github.com/cyberark/conjur-action/compare/v2.0.6...v2.0.7
[2.0.6]: https://github.com/cyberark/conjur-action/compare/v2.0.5...v2.0.6
[2.0.5]: https://github.com/cyberark/conjur-action/releases/tag/v2.0.5
