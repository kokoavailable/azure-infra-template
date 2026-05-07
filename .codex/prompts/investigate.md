Read `AGENTS.md` first.

If the target is under `platform/`, `spokes/`, or `stacks/`, also read the nearest scoped `AGENTS.md`.

Task:
Investigate the requested target before any edits.

Rules:
- Do not edit files.
- Do not run `tofu apply` or `tofu destroy`.
- Prefer Makefile-aware reasoning over raw command assumptions.
- Identify the smallest relevant file set.
- Identify stack, workflow, and documentation boundaries.
- Identify dependency direction.
- Identify blast radius and risks.
- Propose the smallest safe next step.

Output:
1. relevant files
2. current behavior
3. dependency path
4. risks
5. recommended next step
