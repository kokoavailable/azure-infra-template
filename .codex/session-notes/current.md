# Current Session

## Goal

- Add the final operating-loop agent entrypoint that separates automation from human judgment gates.

## Files Read

- `AGENTS.md`
- `docs/codex-workflow.md`
- `docs/agent-workflow.md`
- `docs/runbook.md`
- `docs/ai-native-workflow.md`
- `docs/release-strategy.md`
- `docs/architecture.md`
- `docs/roadmap.md`
- `platform/AGENTS.md`
- `platform/management/03-policy-governance/README.md`
- `platform/identity/README.md`
- `platform/identity/02-identity-federation/README.md`
- `platform/identity/02-identity-federation/main.tf`
- `platform/identity/02-identity-federation/variables.tf`
- `platform/identity/02-identity-federation/outputs.tf`
- `platform/identity/02-identity-federation/locals.tf`
- `.codex/prompts/review.md`
- `.codex/prompts/validate.md`
- `.codex/prompts/diff-review.md`
- `.codex/prompts/session-postmortem.md`
- `.codex/prompts/knowledge-compiler.md`
- `.codex/prompts/operating-loop.md`
- `Makefile`

## Findings

- Repository workflow already requires document-first, inspect-before-edit, and small reviewable changes.
- Codex workflow expectations are documented in `AGENTS.md` and `docs/codex-workflow.md`.
- No existing session note template was present under `.codex/`.
- `docs/runbook.md` has post-incident follow-up guidance, but there is no dedicated troubleshooting notes directory or template.
- Existing `.codex/prompts/` files are short operational prompts and are a good place for reusable agent workflows.
- There is no `docs/learning/` area for concepts the user actually struggled with.
- `AGENTS.md` has a current implementation focus list, but there is no dedicated roadmap with milestones, tasks, and done criteria.
- `docs/release-strategy.md` covers safe promotion and rollback, not the full project completion path.
- There is no durable task history file; `session-notes` captures current work only.
- `platform/management/03-policy-governance/README.md` used raw `terraform` commands instead of the repository Makefile interface.
- Platform change requirements need affected scope, blast radius, validation command, rollback note, and remaining risk.
- `platform/identity/02-identity-federation/README.md` also used raw `terraform` commands instead of the repository Makefile interface.
- The identity stack creates Entra application/service principal resources, GitHub federated credentials, subscription RBAC, and optional tfstate Blob RBAC.
- Prompt files existed, but there were no Makefile targets that rendered prompt-plus-context bundles.
- Level 4 targets rendered specific bundles, but there was no top-level entrypoint for ambiguous work that identifies essence, automation candidates, human gates, validation, and stop conditions.

## Changes

- Added `scripts/agent/render-prompt.sh` to render agent workflow bundles.
- Added `make agent-diff-review`.
- Added `make agent-session-postmortem`.
- Added `make agent-knowledge-compile`.
- Added `.codex/prompts/operating-loop.md`.
- Added `make agent-operating-loop` with optional `TASK=<text>` support.
- Documented executable agent workflows in `docs/codex-workflow.md`, `docs/ai-native-workflow.md`, and `docs/roadmap.md`.

## Validation

- `make docs-fmt` attempted, but failed because Prettier could not write several `.codex/prompts/*.md` files due to `EPERM`.
- Unrelated formatting changes produced before the failure were reverted.
- `npx prettier --check AGENTS.md docs/codex-workflow.md .codex/session-notes/current.md` passed.
- `npx prettier --write docs/runbook.md` applied targeted formatting after `docs/runbook.md` failed check.
- `npx prettier --check AGENTS.md docs/codex-workflow.md docs/runbook.md docs/troubleshooting/README.md docs/troubleshooting/template.md docs/troubleshooting/2026-05-10-docs-fmt-eperm.md .codex/session-notes/current.md` passed.
- `npx prettier --check AGENTS.md docs/codex-workflow.md docs/ai-native-workflow.md docs/runbook.md docs/troubleshooting/README.md docs/troubleshooting/index.md docs/troubleshooting/template.md docs/troubleshooting/2026-05-10-docs-fmt-eperm.md docs/learning/inbox.md .codex/prompts/diff-review.md .codex/prompts/session-postmortem.md .codex/prompts/knowledge-compiler.md .codex/session-notes/current.md` passed.
- `npx prettier --check AGENTS.md docs/roadmap.md .codex/session-notes/current.md` passed.
- `npx prettier --check AGENTS.md docs/codex-workflow.md docs/ai-native-workflow.md docs/roadmap.md docs/task-history/index.md docs/task-history/2026-05.md .codex/session-notes/current.md` passed.
- `npx prettier --check platform/management/03-policy-governance/README.md` passed.
- `make validate STACK=platform/management/03-policy-governance` passed with provider registry access.
- `npx prettier --check platform/identity/02-identity-federation/README.md` passed.
- `make validate STACK=platform/identity/02-identity-federation` passed with provider registry access.
- `bash -n scripts/agent/render-prompt.sh` passed.
- `make help` showed the new `agent-*` targets.
- `make agent-diff-review AGENT_OUT=/private/tmp/agent-diff-review.md` generated a bundle.
- `make agent-session-postmortem AGENT_OUT=/private/tmp/agent-session-postmortem.md` generated a bundle.
- `make agent-knowledge-compile AGENT_OUT=/private/tmp/agent-knowledge-compile.md` generated a bundle.
- `npx prettier --check docs/codex-workflow.md docs/ai-native-workflow.md docs/roadmap.md docs/task-history/2026-05.md .codex/session-notes/current.md` passed.
- `make agent-operating-loop TASK='decide the next platform task safely' AGENT_OUT=/private/tmp/agent-operating-loop.md` generated a bundle.
- `npx prettier --check .codex/prompts/operating-loop.md docs/codex-workflow.md docs/ai-native-workflow.md docs/roadmap.md docs/task-history/2026-05.md .codex/session-notes/current.md` passed.

## Next Step

- Validate Makefile agent targets and update task history.

## Risks

- Agent targets render prompt bundles only; they do not invoke apply, commit files, or make approval decisions.
- Rendered bundles may include local diffs, so they should be reviewed before sharing outside the working context.
