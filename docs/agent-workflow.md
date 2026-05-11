# Agent Workflow

## Purpose

This document defines how agent-style work moves through this repository from architecture decision to portfolio artifact.

The goal is not autonomous infrastructure deployment. The goal is a repeatable operating model where each agent role has a clear input, output, boundary, and validation contract.

## Agent Roles

### Architect

Use when a task changes topology, stack boundaries, environment policy, deployment order, or security assumptions.

Outputs:

- decision summary
- affected boundaries
- accepted trade-offs
- ADR or documentation target
- smallest next implementation scope

### Investigator

Use before implementation when the current structure, dependency path, or risk is not fully known.

Outputs:

- relevant files
- current behavior
- dependency path
- risks
- recommended next step

### Implementer

Use after scope is narrow enough to make a small safe change.

Outputs:

- changed files
- what changed
- verification commands
- validation result
- remaining risks
- next recommended task

### Validator

Use after implementation and before review.

Outputs:

- commands run
- commands intentionally skipped
- validation result
- environment or credential assumptions
- unresolved validation gaps

### Reviewer

Use before merge or when the user asks for review.

Outputs:

- blocking issues
- non-blocking issues
- required fixes
- verification commands
- merge readiness

### Portfolio Curator

Use after a PR or milestone to turn engineering work into interview-ready evidence.

Outputs:

- portfolio narrative
- architecture talking points
- trade-offs and why they were accepted
- validation evidence
- follow-up milestone

## Standard PR Lifecycle

1. Architect frames the decision when the task changes architecture or workflow.
2. Investigator inspects the target area and identifies the smallest safe scope.
3. Implementer changes one stack, workflow, or documentation contract.
4. Validator runs safe formatting and validation commands.
5. Reviewer inspects the diff for operational risk.
6. Portfolio Curator summarizes the work as evidence of engineering judgment.

Small documentation-only changes may skip separate implementation and validation agents when the same Codex session can produce the required outputs clearly.

## Human Gates

Human approval is required for:

- `tofu apply`
- `tofu destroy`
- state mutation commands
- backend migration
- production deployment
- secret rotation
- broad refactors that cross platform, spoke, and workflow boundaries

The human remains responsible for merge and deployment decisions.

## Validation Contract

Default validation:

- documentation-only change: run Prettier check or `make docs-fmt` when safe
- Terraform stack change: run `make fmt` and `make validate STACK=<stack-path>`
- module test change: run `make test MODULE=<module-path>` when applicable
- plan review: run `make plan STACK=<stack-path>` only when expected, credentials are available, and backend access is appropriate

If validation is skipped, the final output must say why.

## Portfolio Contract

Each milestone should be explainable as:

- problem
- design decision
- stack or workflow boundary
- implementation scope
- validation evidence
- operational risk
- rollback or recovery path
- next improvement

Portfolio artifacts should emphasize judgment and safety, not just resource count.

## Example: Dev Utility Access

Architect output:

- Decision: dev utility VM is a documented exception and separate from VMSS runtime.
- Boundary: `25-utility-access` owns mutable operator access; `30-compute` owns application runtime.
- ADR: `docs/adr/0006-separate-utility-access-from-runtime-compute.md`.

Investigator output:

- Inspect `stacks/dev/kr/koreacentral/spokes/app-main/00-spoke-network`, `25-utility-access`, and `30-compute`.
- Confirm network outputs required by utility access.
- Identify public IP, NSG, SSH/RDP, and secret risks.

Implementer output:

- Create or update only the dev `25-utility-access` stack.
- Do not modify `stg`, `prod`, or `30-compute`.

Validator output:

- Run `make fmt`.
- Run `make validate STACK=stacks/dev/kr/koreacentral/spokes/app-main/25-utility-access`.

Reviewer output:

- Check state boundary, public IP restriction, secret handling, and rollback.

Portfolio output:

- Explain the distinction between mutable operator access and immutable runtime compute.
