# AGENTS.md

## Repository role

This repository is an AI-native Azure infrastructure platform template.

It uses:
- OpenTofu for infrastructure as code
- GitHub Actions for CI/CD
- GitHub OIDC for Azure authentication
- Packer for image building
- layered platform/spoke stack boundaries
- Codex for investigation, implementation, validation, and review assistance

The goal is to build a safe, reviewable, production-like Azure platform template.

## Top-level boundaries

- `platform/` contains shared platform infrastructure:
  - connectivity
  - identity
  - management
  - shared services

- `spokes/` contains workload-specific environments:
  - dev
  - stg
  - prod

- `stacks/` contains reusable stack templates and conventions.

- `scripts/bootstrap/` contains one-time or rare bootstrap scripts, especially remote state setup.

- `docs/` contains architecture, ADRs, runbooks, security baseline, naming conventions, layer dependency rules, and release strategy.

- `examples/` contains reference workloads and portfolio-grade examples.

## Current implementation focus

The current priority is not to expand the whole tree at once.

The priority order is:

1. repository hygiene
2. Makefile safety interface
3. platform stack validation
4. bootstrap state workflow
5. GitHub OIDC workflow
6. dev spoke vertical slice
7. reference workload
8. prod hardening

## Safety rules

Never run the following commands unless the user explicitly asks:

- `tofu apply`
- `tofu destroy`
- `tofu state rm`
- `tofu state mv`
- backend migration
- production deployment
- secret rotation

Never hardcode:

- tenant IDs
- subscription IDs
- client secrets
- passwords
- private keys
- real production secret values
- real personal identifiers

Never commit:

- `.terraform/`
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `*.tfplan`
- `.env`
- `node_modules/`
- secret-containing files
- real backend configuration with sensitive values

## Command policy

Use the Makefile as the primary command interface.

Preferred commands:

- `make fmt`
- `make init STACK=<stack-path>`
- `make validate STACK=<stack-path>`
- `make plan STACK=<stack-path>`
- `make check STACK=<stack-path>`

If a Makefile target is missing or broken, explain the problem before using raw `tofu` commands.

Do not run raw `tofu apply` or `tofu destroy`.

## OpenTofu stack rules

This is a multi-stack repository.

Do not assume a global apply.

One stack owns one state.

Cross-stack dependencies must be downstream only.

Do not introduce reverse remote-state dependencies.

Do not introduce cyclic dependencies.

Backend configuration must stay externalized through `backend.hcl` or `backend.hcl.example`.

Environment-specific values must be provided through tfvars or documented bootstrap inputs.

## Platform rules

Platform stacks provide shared infrastructure.

High-risk platform areas:

- DNS
- OIDC
- RBAC
- policy governance
- artifact registry
- shared networking
- production shared services

Any platform change must include:

- affected path
- blast radius
- validation command
- rollback note
- remaining risk

## Spoke rules

Spoke stacks are workload/environment-specific.

Preferred implementation order:

1. `00-spoke-network`
2. `05-secrets`
3. `06-configuration`
4. `20-data`
5. `30-compute`
6. `10-edge`
7. `40-observability`

Do not modify dev, stg, and prod together unless explicitly required.

Start with dev before stg or prod.

Treat prod as high risk.

## Documentation rules

Update documentation when changing:

- stack structure
- module interface
- variables
- outputs
- backend behavior
- CI/CD behavior
- security assumptions
- DNS behavior
- RBAC behavior

Relevant docs:

- `docs/architecture.md`
- `docs/layer-dependency.md`
- `docs/stack-conventions.md`
- `docs/security-baseline.md`
- `docs/runbook.md`
- `docs/release-strategy.md`

## Work process

For non-trivial tasks:

1. Read this file first.
2. Inspect relevant files.
3. Do not edit immediately.
4. Explain the current structure.
5. Identify affected stacks/modules.
6. Identify risks.
7. Propose the smallest safe change.
8. Implement only the requested scope.
9. Run `make fmt`.
10. Run `make validate STACK=<stack-path>` when applicable.
11. Run `make plan STACK=<stack-path>` only when credentials/backend are available and the user expects a plan.
12. Review the diff.
13. Summarize changed files, validation result, and remaining risks.

## Review checklist

Before finishing, check:

- state replacement risk
- backend changes
- provider version changes
- provider lock changes
- remote-state direction
- cyclic dependency risk
- RBAC scope creep
- secret exposure
- DNS delegation impact
- certificate lifecycle impact
- missing variables
- missing outputs
- missing README updates
- missing ADR/runbook updates
- missing validation

## Response format

For implementation tasks, final response must include:

1. changed files
2. what changed
3. verification commands
4. validation result
5. remaining risks
6. next recommended task

For investigation tasks, final response must include:

1. relevant files
2. current behavior
3. dependency path
4. risks
5. recommended next step