# Task History Entry Left With Pending Validation After Interrupted Turn

## Summary

- A task-history entry was added for the agent operating guide, but its
  validation section remained `Pending` after an interrupted turn.
- The generated session postmortem bundle exposed the incomplete entry through
  `git diff`.

## Status

- Open

## Date Observed

- 2026-05-10

## Affected Area

- `docs/task-history/`
- Agent workflow documentation updates
- Interrupted Codex sessions

## Symptom

- `git diff` showed a completed task-history entry with:

```text
Validation:

- Pending.
```

- The entry status was `Completed`, which conflicted with the pending validation
  state.

## Impact

- Task history can become misleading if completed work records do not include
  the actual validation evidence.
- Later reviews may treat the work as less verified than it was, or miss the
  need to run validation before committing.

## Investigation

- `.codex/agent-runs/session-postmortem.md` included the current `git diff`.
- The diff showed only `docs/task-history/2026-05.md` changed.
- The added `Agent Operating Guide` entry listed `Validation: Pending`.
- A targeted Prettier check for the guide, `AGENTS.md`, and task history had
  already passed earlier in the session.

## Likely Cause

- The turn was interrupted after the task-history entry was added but before its
  validation section was updated.

## Mitigation Used

- Identified the incomplete task-history entry through `make agent-diff-review`
  and the generated session postmortem bundle.
- Record this troubleshooting note so future interrupted turns check for
  incomplete task-history validation before commit.

## Permanent Fix

- Update the affected task-history entry with the actual validation command and
  result before committing.
- When a turn is interrupted, resume by checking:

```bash
git status --short
git diff -- docs/task-history/
```

## Prevention Signal

- Before finishing a task, scan task-history entries for `Pending`.
- Treat `Status: Completed` plus `Validation: Pending` as a review blocker.

## Related Files

- `docs/task-history/2026-05.md`
- `.codex/agent-runs/session-postmortem.md`
- `.codex/agent-runs/diff-review.md`
