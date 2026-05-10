# AGENTS.md

## Repository role

This repository is a Codex-native Azure infrastructure platform template.

It uses:

- OpenTofu for infrastructure as code
- GitHub Actions for CI/CD
- GitHub OIDC for Azure authentication
- Packer for image building
- layered platform/spoke stack boundaries
- Codex for investigation, implementation, validation, and review

The repository operating model is:

- document first
- inspect before editing
- keep changes small and reviewable
- prefer Makefile entrypoints
- separate investigation, implementation, and review outputs

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

- `.codex/prompts/` contains repository-standard task prompts for architecture, investigation, implementation, validation, review, and portfolio output.

- `docs/` contains architecture, ADRs, runbooks, safety assumptions, workflow rules, and release strategy.

## Current implementation focus

The current priority is:

1. repository hygiene
2. Makefile safety interface
3. platform stack validation
4. bootstrap state workflow
5. GitHub OIDC workflow
6. dev spoke vertical slice
7. reference workload
8. prod hardening

## Safety rules

Never run the following unless the user explicitly asks:

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
- `make docs-fmt`
- `make init STACK=<stack-path>`
- `make validate STACK=<stack-path>`
- `make plan STACK=<stack-path>`
- `make check STACK=<stack-path>`

If a Makefile target is missing or broken, explain the problem before using raw `tofu` commands.

Do not run raw `tofu apply` or raw `tofu destroy`.

## Codex operating modes

Use these modes consistently:

1. Investigate
   - read `AGENTS.md` and the nearest scoped `AGENTS.md`
   - inspect relevant files before proposing changes
   - explain current structure, affected boundaries, dependencies, and risks
   - do not edit files

2. Implement
   - make the smallest safe change that satisfies the request
   - stay inside the approved scope
   - update documentation when assumptions, interfaces, or workflows change
   - run safe formatting and validation commands when applicable

3. Review
   - review the diff with emphasis on risk
   - focus on state boundaries, backend behavior, dependency direction, RBAC, DNS, secrets, and validation coverage
   - do not praise or restate intent as if it were proof

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

Spoke stacks are workload and environment specific.

Preferred implementation order:

1. `00-spoke-network`
2. `05-secrets`
3. `06-configuration`
4. `20-data`
5. `25-utility-access`
6. `30-compute`
7. `10-edge`
8. `40-observability`

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
- Codex workflow expectations

Relevant docs:

- `docs/architecture.md`
- `docs/layer-dependency.md`
- `docs/stack-conventions.md`
- `docs/security-baseline.md`
- `docs/runbook.md`
- `docs/troubleshooting/README.md`
- `docs/learning/inbox.md`
- `docs/task-history/index.md`
- `docs/roadmap.md`
- `docs/release-strategy.md`
- `docs/agent-workflow.md`
- `docs/codex-workflow.md`
- `docs/ai-native-workflow.md`

## Work process

For non-trivial tasks:

1. Read this file first.
2. Read the nearest scoped `AGENTS.md`.
3. Inspect relevant files.
4. Maintain `.codex/session-notes/current.md` with goal, files read, findings, changes, validation, next step, and risks.
5. Do not edit immediately.
6. Explain the current structure.
7. Identify affected stacks, modules, or workflows.
8. Identify risks and blast radius.
9. Propose the smallest safe change.
10. Implement only the requested scope.
11. Run `make fmt` and `make docs-fmt` when applicable and safe.
12. Run `make validate STACK=<stack-path>` when applicable.
13. Run `make plan STACK=<stack-path>` only when credentials and backend are available and the user expects a plan.
14. Add or update a troubleshooting note when the task exposes a recurring failure, blocked command, confusing workflow, or recovery procedure.
15. Add or update `docs/task-history/` when a task is completed or materially advanced.
16. Review the diff.
17. Summarize changed files, validation result, and remaining risks.

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
- missing ADR or runbook updates
- missing workflow documentation
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
