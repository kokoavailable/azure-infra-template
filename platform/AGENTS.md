# platform/AGENTS.md

## Scope

This directory contains shared platform infrastructure with the largest shared blast radius in the repository.

Typical areas:

- connectivity
- identity
- management
- shared services

## Operating rules

Read root `AGENTS.md` first, then this file.

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

Do not expand platform scope because a dependent spoke would also benefit.

## Dependency rules

Platform is upstream of spokes.

Allowed direction:

- `platform/*` -> shared outputs
- `spokes/*` -> consume platform outputs

Disallowed direction:

- platform stacks depending on spoke state
- reverse remote-state lookups from platform into workload stacks
- cycles between platform domains

## Change requirements

Every platform change must include:

- affected stack path
- affected Azure scope
- blast radius
- validation command
- rollback note
- remaining risk

Call out extra care when touching:

- `platform/connectivity/global/`
- `platform/connectivity/kr/koreacentral/hub/`
- `platform/identity/`
- `platform/management/`
- `platform/shared-services/prod/`

## Review focus

Prioritize review of:

- DNS delegation and resolution behavior
- federated identity subjects and audience assumptions
- RBAC scope growth
- policy assignment inheritance
- shared network route and security impact
- prod versus nonprod boundary leakage
