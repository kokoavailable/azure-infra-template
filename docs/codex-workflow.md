# Codex Workflow

## Purpose

This document defines how Codex should operate in this repository so investigation, implementation, and review stay small, explicit, and safe.

It is the repository-level operating system for AI-assisted work. The role-based workflow is defined in `agent-workflow.md`.

## Core rule

Codex should inspect first, change second, and validate third.

The default behavior is:

1. read `AGENTS.md`
2. read the nearest scoped `AGENTS.md` when present
3. inspect relevant files
4. maintain `.codex/session-notes/current.md` for non-trivial work
5. explain current structure and risk
6. make the smallest safe change
7. run safe formatting or validation commands when applicable
8. review the diff before finishing

## Session Continuity

Codex sessions are disposable. The repository must remain the source of truth for
work state, decisions, validation, and next steps.

For non-trivial work, keep `.codex/session-notes/current.md` updated as the task
progresses. The note should include:

- goal
- files read
- findings
- changes
- validation
- next step
- risks

When a session is interrupted, the next Codex session should resume by reading:

1. `AGENTS.md`
2. the nearest scoped `AGENTS.md`
3. `.codex/session-notes/current.md`
4. `git status --short`
5. `git diff`

Archive completed notes under `.codex/session-notes/archive/` when useful. Do
not use session notes to store secrets, real backend values, credentials, tenant
IDs, subscription IDs, or production identifiers.

## Troubleshooting Notes

Session notes are short-lived recovery context. Troubleshooting notes are
durable project memory.

When a task exposes a recurring failure, blocked command, confusing workflow, or
recovery procedure, add or update an entry under `docs/troubleshooting/`.

A troubleshooting note should capture:

- symptom
- impact
- affected files or commands
- likely cause
- mitigation used
- permanent fix or follow-up
- prevention signal

Troubleshooting notes must stay sanitized. Do not record secrets, credentials,
tenant IDs, subscription IDs, real backend values, production identifiers, or
personal data.

## Learning Notes

Learning notes are for concepts the user actually struggled with during project
work. They are not a general knowledge base.

When a session exposes a concept that blocked progress or required explanation,
append a short entry to `docs/learning/inbox.md` with:

- concept
- one-line definition
- why it matters in this repository
- file or command to revisit
- five-minute review question

Keep the daily volume small. Prefer three to five useful entries over a large
set of generic flashcards.

## Task History

Task history is the durable chronology of completed or materially advanced work.
It is separate from session notes.

Use:

- `.codex/session-notes/current.md` for the current task and restart context
- `docs/task-history/` for completed work and follow-up continuity
- `docs/troubleshooting/` for failures, diagnosis, mitigation, and prevention

When a task finishes or reaches a meaningful checkpoint, add a short entry to
the current monthly task history file. Each entry should capture:

- task
- status
- changed files or areas
- validation
- follow-up
- related troubleshooting or learning notes

Keep entries factual and compact. Do not duplicate full postmortems or copy long
diff summaries into task history.

## Automation Boundary

Codex may automate recording, summarizing, drafting, and verification support.

Allowed automation:

- command summaries
- postmortem or troubleshooting drafts
- runbook updates
- diff review maps
- concept extraction
- review cards
- checklists

Human judgment remains required for:

- final architecture decisions
- security exceptions
- RBAC scope decisions
- production change approval
- root-cause claims that have not been verified

Separate facts from assumptions. Use `Possible cause` for unverified
explanations.

## Makefile Agent Workflows

The repository exposes repeatable agent workflow entrypoints through the
Makefile. These targets render a prompt plus relevant repository context. They
do not apply infrastructure changes and do not make approval decisions.

Use:

```bash
make agent-operating-loop TASK="describe the next task"
make agent-diff-review
make agent-session-postmortem
make agent-knowledge-compile
```

To save a rendered bundle:

```bash
make agent-diff-review AGENT_OUT=.codex/agent-runs/diff-review.md
```

These targets are the Level 4 bridge between prompt files and repeatable
operator workflows. A human still decides whether to accept the generated review,
postmortem, task-history update, or learning entry.

The highest-level loop is `make agent-operating-loop`. Use it before ambiguous
or high-risk work. It should separate:

- the essence of the work
- the affected repository boundary
- automatable tasks
- human decision gates
- validation plan
- stop conditions

## Operating modes

### Architect

Use architect mode when the task changes topology, stack boundaries, environment policy, deployment order, security assumptions, or workflow rules.

Expected behavior:

- identify the decision being made
- identify affected boundaries and blast radius
- document trade-offs
- recommend an ADR or documentation target
- define the smallest safe implementation scope

Expected output:

1. decision summary
2. affected boundaries
3. accepted trade-offs
4. ADR or documentation target
5. smallest next implementation scope

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

### Validate

Use validate mode after implementation and before review.

Expected behavior:

- use Makefile entrypoints when possible
- run formatting checks for documentation-only changes
- run stack validation for stack-scoped changes when applicable
- avoid apply, destroy, state mutation, and unexpected plan execution
- state skipped validation explicitly

Expected output:

1. commands run
2. commands skipped
3. validation result
4. assumptions
5. unresolved validation gaps

### Portfolio

Use portfolio mode after a PR or milestone.

Expected behavior:

- convert the work into interview-ready evidence
- distinguish verified implementation from design intent
- explain trade-offs and remaining risks
- identify the next milestone

Expected output:

1. portfolio narrative
2. architecture talking points
3. trade-offs
4. validation evidence
5. remaining risks
6. next milestone

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
- `stacks/` contains deployed environment hub-and-spoke stacks
- `templates/` defines reusable conventions and templates
- `scripts/bootstrap/` is bootstrap-only and should remain deliberate
- `docs/` is part of the architecture contract, not optional cleanup

Dependency direction must remain:

1. platform prerequisites
2. environment hub connectivity
3. environment spoke network and configuration
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
- [agent-workflow.md](/Users/baesangdo/private/azure-infra-template/docs/agent-workflow.md)

## PR shape

A Codex-driven PR should usually be:

- single-purpose
- explicit about scope and non-scope
- clear about dependency direction
- clear about validation performed
- clear about remaining risk

The PR template should be treated as required operating metadata, not optional prose.
