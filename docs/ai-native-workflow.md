# AI-Native Workflow

## Purpose

This repository is designed for humans and Codex to work together on infrastructure safely.

AI-native does not mean autonomous apply. It means repository conventions, prompts, PRs, and docs are structured so AI work stays reviewable.

## Workflow principles

1. The repository contract lives in `AGENTS.md`, scoped `AGENTS.md` files, prompt files, and workflow docs.
2. AI should inspect local context before editing.
3. Every non-trivial change should explain structure, dependency direction, and risk.
4. Small PRs are preferred over broad speculative refactors.
5. Documentation is part of the delivery artifact.
6. Human review remains responsible for merge and deployment decisions.

## Human and Codex responsibilities

### Human responsibilities

- define scope
- approve high-risk direction
- review risk notes and validation
- decide whether plan or apply should happen
- protect prod and shared platform boundaries

### Codex responsibilities

- read repository instructions first
- keep changes inside the approved scope
- avoid destructive commands unless explicitly requested
- prefer Makefile interfaces
- surface risks, assumptions, and missing context
- update docs when contracts change

## Standard task flow

### 1. Investigate

Codex should:

- inspect the target area
- identify relevant files
- explain current behavior
- map dependency direction
- identify risks
- recommend the smallest safe next step

### 2. Implement

Codex should:

- change only the approved scope
- keep stack ownership and state boundaries intact
- avoid unrelated cleanup
- run safe formatting and validation when applicable
- summarize what changed and what remains risky

### 3. Review

Codex or a human reviewer should:

- inspect the final diff
- verify docs and validation coverage
- check backend, dependency, RBAC, DNS, and secret risks
- confirm rollback notes are sensible

## Prompt contract

The repository ships prompt files under `.codex/prompts/`:

- `architect.md`
- `diff-review.md`
- `investigate.md`
- `implement.md`
- `knowledge-compiler.md`
- `validate.md`
- `review.md`
- `session-postmortem.md`
- `portfolio.md`

These prompts are lightweight wrappers around the repository rules and the role model in `docs/agent-workflow.md`. They should stay aligned with:

- root `AGENTS.md`
- scoped `platform/AGENTS.md`
- scoped `spokes/AGENTS.md`
- scoped `stacks/AGENTS.md`
- `docs/agent-workflow.md`
- the pull request template

If one changes materially, the others should be reviewed for drift.

## Validation model

Safe validation typically means:

- `make fmt`
- `make docs-fmt`
- `make validate STACK=<stack-path>` for stack-scoped changes

`make plan STACK=<stack-path>` is conditional and should run only when:

- the user expects a plan
- credentials are available
- backend access is appropriate for the task

`tofu apply` and `tofu destroy` are outside the default AI workflow.

## PR expectations

An AI-native PR should make the following easy to review:

- what changed
- what did not change
- what boundary was affected
- which dependencies matter
- what validation ran
- what risk remains
- how rollback would work

Documentation-only and workflow-only PRs should stay documentation-only and workflow-only.

## Knowledge Capture

AI should turn repeated work and mistakes into reusable project knowledge.

Use:

- `docs/runbook.md` for repeatable procedures
- `docs/troubleshooting/` for failures, diagnosis, recovery, and prevention
- `docs/learning/inbox.md` for concepts the user actually struggled with
- `docs/task-history/` for completed task chronology
- `docs/codex-workflow.md` for agent operating rules
- `.codex/session-notes/current.md` for temporary task context

AI may draft summaries, notes, checklists, and review maps. Humans still own
architecture judgment, security exceptions, permission boundaries, production
approval, and final root-cause acceptance.

## Executable Agent Workflows

Prompt files under `.codex/prompts/` are connected to Makefile targets:

- `make agent-operating-loop`
- `make agent-diff-review`
- `make agent-session-postmortem`
- `make agent-knowledge-compile`

Each target renders an agent-ready bundle with the prompt and relevant local
context such as session notes, git status, diffs, task history, troubleshooting
index, or learning inbox.

Use `AGENT_OUT=<file>` to save the bundle for review or reuse. These targets
prepare agent work; they do not approve infrastructure changes, run apply, or
commit generated notes automatically.

Use `make agent-operating-loop` as the default entrypoint when the next action is
unclear. It turns a user request into a structured operating loop:

- essence
- boundary
- automatable work
- human judgment gates
- validation
- documentation updates
- next tasks

## Drift control

To avoid instruction drift:

1. update repository and scoped `AGENTS.md` files together when operating rules change
2. update prompt files when output contracts change
3. update the PR template when reviewers need new risk metadata
4. update this document and `docs/codex-workflow.md` when the operating model changes
