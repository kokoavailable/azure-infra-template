# platform/AGENTS.md

## Scope

This directory contains shared platform infrastructure.

Platform changes have a larger blast radius than spoke changes.

## Rules

Be conservative with:

- DNS
- OIDC
- RBAC
- Azure Policy
- shared networking
- artifact registry
- production shared services

Do not modify multiple platform domains in one task unless explicitly required.

Do not mix prod and nonprod platform changes unless explicitly required.

Every platform change must include:

- affected stack
- affected Azure scope
- validation command
- blast radius
- rollback note