Read AGENTS.md first.

Implement the smallest safe change for the requested target.

Rules:
- Stay inside the requested scope.
- Do not run apply or destroy.
- Do not modify backend configuration unless requested.
- Do not hardcode secrets or real environment values.
- Use Makefile commands when possible.
- Run fmt.
- Run validate when applicable.

Output:
1. changed files
2. what changed
3. verification commands
4. validation result
5. remaining risks
6. next recommended task