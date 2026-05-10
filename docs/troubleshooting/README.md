# Troubleshooting Notes

## Purpose

This directory stores durable troubleshooting notes for project problems that
are likely to recur or that required non-obvious diagnosis.

Use these notes for:

- failed repository commands
- local tooling or permission problems
- OpenTofu validation or backend issues
- CI/OIDC authentication failures
- stack dependency ordering problems
- DNS, RBAC, secret, or certificate recovery procedures
- Codex workflow failures that future sessions should recognize

Use `docs/runbook.md` for standard operating procedure. Use ADRs for long-term
architecture decisions. Use troubleshooting notes for observed problems,
diagnosis, mitigation, and prevention.

Use `index.md` as the entry point. Add a link there whenever a new note is
created.

## Naming

Use dated, descriptive filenames:

```text
YYYY-MM-DD-short-problem-name.md
```

Examples:

```text
2026-05-10-docs-fmt-eperm.md
2026-05-10-oidc-audience-mismatch.md
2026-05-10-backend-lock-timeout.md
```

## Required Sections

Each note should include:

- summary
- status
- date observed
- affected area
- symptom
- impact
- investigation
- likely cause
- mitigation used
- permanent fix
- prevention signal
- related files

## Safety

Do not store secrets, credentials, tenant IDs, subscription IDs, real backend
values, production identifiers, or personal data in troubleshooting notes.

Prefer sanitized command output and repository-relative paths.
