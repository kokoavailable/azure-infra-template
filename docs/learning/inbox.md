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
