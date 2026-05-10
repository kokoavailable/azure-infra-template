Read `AGENTS.md` first.

Task:
Compile today's work into reusable project knowledge.

Inputs to inspect:

- `git diff --stat`
- `git log --oneline -5`
- `.codex/session-notes/current.md`
- `docs/runbook.md`
- `docs/troubleshooting/`
- `docs/learning/inbox.md`
- failed commands and validation notes from the conversation

Output:

1. problems solved today
2. concepts learned or clarified
3. repeatable procedures
4. automation candidates
5. tomorrow's first three tasks
6. docs updated

Document updates:

- update `.codex/session-notes/current.md` when current context changed
- update `docs/learning/inbox.md` only for concepts the user actually struggled with
- update `docs/troubleshooting/index.md` when new troubleshooting notes are added
- update `docs/runbook.md` only for repeatable procedures

Rules:

- Keep entries short and operational.
- Do not create generic glossary entries.
- Limit learning entries to three to five useful concepts per day.
- Separate facts from assumptions.
- Use actual commands from this repository.
- Do not make architecture, security, RBAC, or production approval decisions.
