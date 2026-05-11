# Agent Operating Guide

## Purpose

This guide explains how to run this project through the agent workflow.

Use it when you are about to start work, decide the next task, review a diff, or
turn mistakes into reusable project memory.

## Mental Model

The repository is the operating system.

Codex helps with:

- structuring work
- reading local context
- drafting changes
- summarizing diffs
- producing troubleshooting or learning notes
- suggesting validation commands

The human owns:

- priority
- approval
- architecture decisions
- RBAC and security exceptions
- production changes
- final root-cause acceptance

## Default Loop

Use this loop for non-trivial work:

```text
1. Generate operating loop
2. Review human decision gates
3. Let Codex implement only the approved safe scope
4. Validate with Makefile commands
5. Generate diff review bundle
6. Review suspicious or out-of-scope changes
7. Update task history, troubleshooting, or learning notes
8. Commit when the diff is small and explainable
```

## 1. Start With Operating Loop

Run:

```bash
make agent-operating-loop TASK="choose the next safe platform task after management and identity README handoff" AGENT_OUT=".codex/agent-runs/next-platform-task.md"
```

Then ask Codex:

```text
.codex/agent-runs/next-platform-task.md 읽고 다음 태스크를 진행해줘.
단, human decision gates는 내가 승인하기 전까지 넘지 마.
```

Expected output:

- essence of the work
- affected boundary
- automatable work
- human decision gates
- safe next command or edit
- validation plan
- stop conditions

## 2. Human Decision Gates

Codex may not cross these without explicit approval:

- `tofu apply`
- `tofu destroy`
- state mutation
- backend migration
- production deployment
- secret rotation
- RBAC scope expansion
- DNS delegation changes
- security exceptions
- final architecture decisions
- unverified root-cause claims

If a task reaches one of these gates, stop and ask for human approval.

## 3. Implement the Approved Scope

Keep implementation small:

- one stack, document, or workflow boundary at a time
- no unrelated cleanup
- no broad refactors
- no dev/stg/prod combined changes unless explicitly approved
- no platform scope expansion just because spokes might benefit

Use Makefile entrypoints:

```bash
make fmt
make validate STACK=<stack-path>
make docs-fmt
```

Run `make plan STACK=<stack-path>` only when the user expects a plan and
credentials/backend access are appropriate.

## 4. Review the Diff

Run:

```bash
make agent-diff-review AGENT_OUT=".codex/agent-runs/diff-review.md"
```

Then ask Codex:

```text
.codex/agent-runs/diff-review.md 기준으로 리뷰 맵을 만들어줘.
수정하지 말고 리뷰만 해.
```

Use the output to inspect:

- suspicious changes
- files outside requested scope
- missing validation
- backend, state, RBAC, DNS, provider, secret, or CI/CD risks

## 5. Capture Failures

When a command fails or the same problem may recur, run:

```bash
make agent-session-postmortem AGENT_OUT=".codex/agent-runs/session-postmortem.md"
```

Then ask Codex:

```text
.codex/agent-runs/session-postmortem.md 기준으로 troubleshooting note 초안을 만들어줘.
이미 같은 문제가 있으면 새 파일 만들지 말고 기존 docs/troubleshooting 항목을 업데이트해.
```

Store durable failure knowledge under `docs/troubleshooting/`.

## 6. End of Day

Run:

```bash
make agent-knowledge-compile AGENT_OUT=".codex/agent-runs/knowledge-compile.md"
```

Then ask Codex:

```text
.codex/agent-runs/knowledge-compile.md 기준으로 오늘 작업을 정리해줘.
docs/task-history, docs/learning/inbox, docs/troubleshooting/index 중 필요한 것만 업데이트해.
```

Use:

- `docs/task-history/` for completed work
- `docs/learning/inbox.md` only for concepts that actually caused confusion
- `docs/troubleshooting/` for reusable failure diagnosis

## Storage Rules

Generated bundles go under `.codex/agent-runs/`.

That directory is ignored because bundles may include local diffs, command
output, or task context. Do not commit generated bundles unless a specific
artifact is intentionally sanitized and promoted into `docs/`.

## Quick Commands

```bash
make agent-operating-loop TASK="..." AGENT_OUT=".codex/agent-runs/operating-loop.md"
make agent-diff-review AGENT_OUT=".codex/agent-runs/diff-review.md"
make agent-session-postmortem AGENT_OUT=".codex/agent-runs/session-postmortem.md"
make agent-knowledge-compile AGENT_OUT=".codex/agent-runs/knowledge-compile.md"
```

## Current Next Move

After the management, identity, and public DNS README handoffs, the next safe
move is usually one of:

- run `make agent-diff-review` and review the current diff
- continue platform connectivity handoff with
  `stacks/dev/kr/koreacentral/hub/00-hub-network`
- fix or intentionally scope the known `make docs-fmt` formatting blocker
