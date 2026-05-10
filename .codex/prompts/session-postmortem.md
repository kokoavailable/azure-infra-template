Read `AGENTS.md` first.

Task:
Turn the current session into a troubleshooting or postmortem draft.

Inputs to inspect:

- `.codex/session-notes/current.md`
- `git status --short`
- `git diff --stat`
- `git diff`
- failed commands and validation notes from the conversation
- `docs/runbook.md`
- `docs/troubleshooting/`

Output sections:

1. what happened
2. why it happened
3. impact
4. fix
5. verification
6. prevention
7. reusable lesson
8. unresolved follow-up
9. related files
10. example commands

Rules:

- Facts only.
- Put unverified explanations under `Possible cause`.
- Do not duplicate an existing troubleshooting note.
- If the issue matches an existing note, update that note instead of creating a new one.
- If a new note is needed, create `docs/troubleshooting/YYYY-MM-DD-short-title.md`.
- Add new troubleshooting notes to `docs/troubleshooting/index.md`.
- Do not store secrets, credentials, tenant IDs, subscription IDs, backend values, production identifiers, or personal data.
