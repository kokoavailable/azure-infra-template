# Agent Workflow Drifts Into Documentation Loop

## Problem

Agent workflow commands and knowledge-system prompts were being used heavily, but
project progress felt slower because the loop spent too much time generating
notes, prompt bundles, postmortems, and handoff documents before making
implementation changes.

## Symptoms

- Repeated workflow and documentation updates.
- Platform scaffold README handoffs advanced, but actual OpenTofu stack
  implementation lagged behind.
- `make agent-operating-loop` generated context bundles, but did not itself
  choose or implement the next task.
- The user had to ask whether the workflow was actually moving the project
  forward.

## Root Cause

- `make agent-operating-loop`, `make agent-diff-review`, and
  `make agent-session-postmortem` are prompt/context renderers, not autonomous
  implementation runners.
- The operating loop missed a hard transition from investigation/review into a
  small implementation task.
- Postmortem and troubleshooting steps were treated as always-on work instead of
  conditional closing steps.

## Impact

- Lower perceived productivity.
- More documentation churn than project movement.
- Ambiguous handoff between "prepare context for the agent" and "implement the
  next safe change."

## Fix

Use this order for normal project work:

```text
1. Pick one small implementation task.
2. Identify human decision gates.
3. Implement only the approved or safe portion.
4. Validate with Makefile commands.
5. Run diff review.
6. Update session notes and task history.
7. Add postmortem/troubleshooting/learning only when the session exposed a
   reusable failure, recovery pattern, or concept the user actually struggled with.
```

For the hub network task, the fix was to add a real OpenTofu scaffold for
`platform/connectivity/kr/koreacentral/hub/00-hub-network` while leaving CIDR and
subnet layout as human-approved inputs.

## Verification

```bash
make fmt
make validate STACK=platform/connectivity/kr/koreacentral/hub/00-hub-network
make agent-diff-review AGENT_OUT=.codex/agent-runs/diff-review.md
make agent-session-postmortem AGENT_OUT=.codex/agent-runs/session-postmortem.md
```

## Prevention

- Treat `agent-*` Makefile targets as context generators unless a future target
  explicitly executes implementation.
- Do not run postmortem/troubleshooting/learning updates by default for every
  task.
- For "next task" requests, prioritize implementation work first and close with
  lightweight records.
- Ask: "Which repo file should materially change next?" before creating new
  workflow documents.

## Reusable Lesson

Agent-native development needs a production loop, not just a memory loop.
Knowledge capture is valuable only after it helps implementation move faster.

## Related Files

- `Makefile`
- `.codex/prompts/operating-loop.md`
- `.codex/prompts/diff-review.md`
- `.codex/prompts/session-postmortem.md`
- `docs/agent-operating-guide.md`
- `platform/connectivity/kr/koreacentral/hub/00-hub-network/`
