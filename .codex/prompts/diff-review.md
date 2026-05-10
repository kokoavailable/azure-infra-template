Read `AGENTS.md` first.

Task:
Review the current `git diff` without editing files.

Inputs to inspect:

- `git status --short`
- `git diff --stat`
- `git diff`
- `.codex/session-notes/current.md` when present

Output:

1. changed files grouped by purpose
2. intended changes
3. suspicious changes
4. files outside requested scope
5. commands needed for verification
6. suggested commit message

Rules:

- Do not modify files.
- Separate facts from assumptions.
- Call out unrelated formatting churn.
- Call out backend, state, RBAC, DNS, secret, provider, and CI/CD risk.
- Prefer concrete file references.
