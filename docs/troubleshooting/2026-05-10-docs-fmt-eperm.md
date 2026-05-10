# `make docs-fmt` Fails on `.codex/prompts` with `EPERM`

## Summary

- `make docs-fmt` attempted to format repository Markdown but failed when
  Prettier could not write several `.codex/prompts/*.md` files.
- The requested workflow-documentation change was still validated with targeted
  Prettier checks.

## Status

- Mitigated

## Date Observed

- 2026-05-10

## Affected Area

- Documentation formatting workflow
- `.codex/prompts/*.md`
- `make docs-fmt`

## Symptom

- `make docs-fmt` returned exit code 2.
- Prettier reported `EPERM: operation not permitted` while opening several
  prompt files under `.codex/prompts/`.

## Impact

- Repository-wide documentation formatting could not complete.
- Prettier formatted unrelated Markdown files before failing, which created
  noisy out-of-scope diffs.

## Investigation

- `make docs-fmt` was run after a documentation-only workflow change.
- The failure occurred on existing `.codex/prompts/*.md` files rather than on
  the files changed by the task.
- `git status --short` showed broad Markdown changes caused by the partial
  formatting run.
- The unrelated formatting changes were reverted.
- Targeted checks passed for the files changed by the task.

## Likely Cause

- Some `.codex/prompts/*.md` files are not writable in the current execution
  context, even though they are visible in the workspace.

## Mitigation Used

- Reverted the unrelated formatting changes created before the failure.
- Ran targeted Prettier checks against the affected files:

```bash
npx prettier --check AGENTS.md docs/codex-workflow.md .codex/session-notes/current.md
npx prettier --check .codex/session-notes/current.md
```

## Permanent Fix

- Investigate why `.codex/prompts/*.md` cannot be written by the documentation
  formatter.
- Either fix file permissions or adjust `make docs-fmt` so generated or
  protected prompt files are handled intentionally.

## Prevention Signal

- `make docs-fmt` should complete without partial formatting side effects.
- If it fails, check `git status --short` for unrelated formatting changes
  before continuing.

## Related Files

- `Makefile`
- `.codex/prompts/`
- `AGENTS.md`
- `docs/codex-workflow.md`
- `.codex/session-notes/current.md`
