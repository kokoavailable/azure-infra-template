Read `AGENTS.md` first.

If the target is under `platform/`, `spokes/`, or `stacks/`, also read the nearest scoped `AGENTS.md`.

Task:
Implement the smallest safe change for the requested scope.

Rules:
- Stay inside the requested scope.
- Do not modify unrelated stacks or modules.
- Do not run `tofu apply` or `tofu destroy`.
- Do not modify backend behavior unless requested.
- Do not hardcode secrets or real environment values.
- Use Makefile commands when possible.
- Run safe formatting commands when available.
- Run validation only when applicable to the changed scope.
- Review the diff before finishing.

Output:
1. changed files
2. what changed
3. verification commands
4. validation result
5. remaining risks
6. next recommended task
