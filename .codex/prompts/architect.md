Read `AGENTS.md` first.

If the target is under `platform/`, `spokes/`, or `stacks/`, also read the nearest scoped `AGENTS.md`.

Task:
Frame the architecture decision before implementation.

Use when the task affects topology, stack boundaries, environment policy, deployment order, security assumptions, or workflow rules.

Rules:

- Do not edit infrastructure files unless the user explicitly asks for implementation.
- Prefer ADR or documentation updates for durable decisions.
- Identify platform, spoke, stack, workflow, and portfolio boundaries.
- Identify blast radius, dependency direction, and rollback implications.
- Propose the smallest safe implementation scope.

Output:

1. decision summary
2. affected boundaries
3. accepted trade-offs
4. ADR or documentation target
5. smallest next implementation scope
