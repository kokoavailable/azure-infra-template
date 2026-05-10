Read `AGENTS.md` first.

Task:
Turn the user's current work request into an operating loop.

Goal:
Reveal the essence of the work, structure it, identify what can be automated,
and mark where human judgment must intervene.

Inputs to inspect:

- `AGENTS.md`
- nearest scoped `AGENTS.md` when the task touches `platform/`, `spokes/`, or `stacks/`
- `.codex/session-notes/current.md`
- `docs/roadmap.md`
- `docs/codex-workflow.md`
- `docs/ai-native-workflow.md`
- `docs/task-history/`
- `docs/troubleshooting/`
- `docs/learning/inbox.md`
- current `git status --short`
- current `git diff --stat`
- current `git diff`

Output:

1. essence of the work
2. repo boundary affected
3. current state
4. automatable work
5. human decision gates
6. safe next command or edit
7. validation plan
8. documentation updates needed
9. risks and stop conditions
10. next three tasks

Rules:

- Do not make approval decisions.
- Do not approve architecture, RBAC, security exceptions, production changes, or root-cause claims.
- Separate facts from assumptions.
- Put unverified explanations under `Possible cause`.
- Prefer Makefile entrypoints.
- Keep the suggested next action small enough to review.
- If the task belongs in `docs/troubleshooting/`, `docs/learning/inbox.md`, or `docs/task-history/`, say exactly where.
