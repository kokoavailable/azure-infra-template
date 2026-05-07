# Codex Workflow

## Purpose

This document defines how Codex should operate in this repository so investigation, implementation, and review stay small, explicit, and safe.

It is the repository-level operating system for AI-assisted work.

## Core rule

Codex should inspect first, change second, and validate third.

The default behavior is:

1. read `AGENTS.md`
2. read the nearest scoped `AGENTS.md` when present
3. inspect relevant files
4. explain current structure and risk
5. make the smallest safe change
6. run safe formatting or validation commands when applicable
7. review the diff before finishing

## Operating modes

### Investigate

Use investigation mode when the user is asking how something works, what should change, or what the safest path is.

Expected behavior:

- no file edits
- no apply or destroy
- identify the smallest relevant file set
- explain boundaries and dependencies
- call out risks and unknowns
- recommend the next safe step

Expected output:

1. relevant files
2. current behavior
3. dependency path
4. risks
5. recommended next step

### Implement

Use implementation mode when the user wants a scoped change.

Expected behavior:

- stay inside the requested scope
- do not widen the PR without clear need
- preserve stack and state boundaries
- update docs when workflow, assumptions, interfaces, or behavior change
- use Makefile commands when possible
- avoid raw destructive OpenTofu commands

Expected output:

1. changed files
2. what changed
3. verification commands
4. validation result
5. remaining risks
6. next recommended task

### Review

Use review mode when the user asks for a review or when a diff needs a final risk pass.

Expected behavior:

- findings first
- focus on operational and architectural risk
- do not confuse intended behavior with verified behavior
- highlight missing validation, docs, or rollback notes

Expected output:

1. blocking issues
2. non-blocking issues
3. required fixes
4. verification commands
5. merge readiness

## Command policy

Prefer the Makefile as the stable operator interface.

Common safe commands:

- `make fmt`
- `make docs-fmt`
- `make validate STACK=<stack-path>`
- `make test MODULE=<module-path>` when module tests are the direct scope

Conditionally allowed:

- `make plan STACK=<stack-path>` only when the user expects a plan and credentials/backend are available

Disallowed without explicit user request:

- `tofu apply`
- `tofu destroy`
- state mutation commands
- backend migration

## Boundary model

Codex should reason in repository boundaries before editing:

- `platform/` is shared and high blast radius
- `spokes/` is workload and environment specific
- `stacks/` defines reusable conventions and templates
- `scripts/bootstrap/` is bootstrap-only and should remain deliberate
- `docs/` is part of the architecture contract, not optional cleanup

Dependency direction must remain:

1. platform prerequisites
2. hub or shared connectivity
3. spoke network and configuration
4. data services
5. compute
6. observability

Reverse remote-state dependencies and cycles are not allowed.

## Documentation contract

Codex should update documentation when a change affects:

- stack structure
- module interfaces
- variables or outputs
- CI/CD behavior
- backend behavior
- security assumptions
- DNS or RBAC behavior
- Codex workflow expectations

Relevant documents include:

- [architecture.md](/Users/baesangdo/private/azure-infra-template/docs/architecture.md)
- [stack-conventions.md](/Users/baesangdo/private/azure-infra-template/docs/stack-conventions.md)
- [security-baseline.md](/Users/baesangdo/private/azure-infra-template/docs/security-baseline.md)
- [release-strategy.md](/Users/baesangdo/private/azure-infra-template/docs/release-strategy.md)
- [ai-native-workflow.md](/Users/baesangdo/private/azure-infra-template/docs/ai-native-workflow.md)

## PR shape

A Codex-driven PR should usually be:

- single-purpose
- explicit about scope and non-scope
- clear about dependency direction
- clear about validation performed
- clear about remaining risk

The PR template should be treated as required operating metadata, not optional prose.
