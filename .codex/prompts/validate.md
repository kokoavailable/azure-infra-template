Read `AGENTS.md` first.

If the target is under `platform/`, `spokes/`, or `stacks/`, also read the nearest scoped `AGENTS.md`.

Task:
Validate the changed scope using safe repository entrypoints.

Rules:

- Prefer Makefile targets over raw commands.
- Do not run `tofu apply` or `tofu destroy`.
- Do not run `make plan` unless the user expects a plan and credentials/backend are available.
- For documentation-only changes, run Prettier check or `make docs-fmt` when safe.
- For stack changes, run `make fmt` and `make validate STACK=<stack-path>` when applicable.
- State clearly when validation is skipped.

Output:

1. commands run
2. commands skipped
3. validation result
4. assumptions
5. unresolved validation gaps
