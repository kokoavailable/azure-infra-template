# Learning Inbox

This file captures concepts the user actually struggled with during project
work. It is not a general glossary.

Keep entries short and operational. Prefer three to five useful entries per day.

## Entry Template

```text
## YYYY-MM-DD - <Concept>

- Definition:
- Why it matters here:
- Revisit:
- Five-minute review:
```

## 2026-05-10 - Session Notes vs Troubleshooting Notes

- Definition: Session notes preserve temporary task context; troubleshooting
  notes preserve durable failure diagnosis and recovery knowledge.
- Why it matters here: Codex sessions can be interrupted, while recurring
  workflow failures should become reusable project memory.
- Revisit: `.codex/session-notes/current.md`, `docs/troubleshooting/index.md`,
  `docs/codex-workflow.md`
- Five-minute review: When should a note stay in session context, and when
  should it be promoted to `docs/troubleshooting/`?

## 2026-05-10 - Targeted Formatting Checks

- Definition: A targeted formatting check validates only the files in scope
  instead of formatting the whole repository.
- Why it matters here: `make docs-fmt` currently fails on `.codex/prompts/*.md`
  with `EPERM`, so targeted checks keep documentation-only changes reviewable
  without accepting unrelated formatting churn.
- Revisit: `docs/troubleshooting/2026-05-10-docs-fmt-eperm.md`
- Five-minute review: Why is a targeted Prettier check safer than accepting a
  broad partial formatting diff after a failed command?

## 2026-05-10 - Agent Context Bundle vs Implementation Loop

- Definition: An agent context bundle packages instructions and repo state for
  review; an implementation loop actually changes repo files, validates them,
  reviews the diff, and records only useful knowledge.
- Why it matters here: `make agent-operating-loop` helps structure the next
  action, but it does not itself implement the platform stack.
- Revisit: `Makefile`, `.codex/prompts/operating-loop.md`,
  `docs/troubleshooting/2026-05-10-agent-workflow-documentation-loop.md`
- Five-minute review: When should an agent workflow stop generating context and
  start changing the next project file?

## 2026-05-16 - Hub VNet Learning Path

- Definition: A hub VNet is the shared network control plane for an environment,
  while spokes own workload-specific network and application resources.
- Why it matters here: The dev hub stacks define shared VNet, private DNS,
  egress routing, and access operations that downstream spokes should consume
  without creating reverse dependencies.
- Revisit: `docs/learning/hub-vnet-learning-notes.md`,
  `stacks/dev/kr/koreacentral/hub/`
- Five-minute review: Why should a spoke read hub outputs, but the hub avoid
  reading spoke state?
