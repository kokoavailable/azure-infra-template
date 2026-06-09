# Current Session

## Goal

- Move from documentation-only handoff into actual platform implementation by
  adding the first safe OpenTofu scaffold for the Korea Central hub network.

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
- `platform/connectivity/global/00-dns-public/README.md`
- `platform/connectivity/global/00-dns-public/main.tf`
- `platform/connectivity/global/00-dns-public/variables.tf`
- `platform/connectivity/global/00-dns-public/outputs.tf`
- `platform/connectivity/global/00-dns-public/locals.tf`
- `platform/connectivity/global/00-dns-public/terraform.tfvars.example`
- `platform/connectivity/kr/koreacentral/hub/00-hub-network/README.md`
- `platform/connectivity/kr/koreacentral/hub/05-private-dns/README.md`
- `platform/connectivity/kr/koreacentral/hub/10-egress-routing-security/README.md`
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
- `platform/connectivity/global/00-dns-public/README.md` used raw `terraform` commands instead of the repository Makefile interface.
- Public DNS has an external human gate: registrar NS delegation is outside Azure state and must not be treated as automatic.
- Generated `.codex/agent-runs/` bundles may include local diff/context and should not be committed.
- `platform/connectivity/kr/koreacentral/hub/00-hub-network` is a README-only scaffold with no `.tf` files yet.
- Hub network design has human decision gates for CIDR, subnet layout, peering, routes, firewall, Bastion, and production connectivity assumptions.
- `platform/connectivity/kr/koreacentral/hub/05-private-dns` is a README-only scaffold with no `.tf` files yet.
- Private DNS design has human decision gates for centralized zone list, VNet link registration policy, hybrid resolver assumptions, production resolution, and migration from duplicate zones.
- `platform/connectivity/kr/koreacentral/hub/10-egress-routing-security` is a README-only scaffold with no `.tf` files yet.
- Egress routing security design has human decision gates for forced tunneling, firewall policy, default routes, NAT ownership, route associations, production egress behavior, and broad allow rules.
- `platform/connectivity/kr/koreacentral/hub/00-hub-network` can advance safely
  as an input-driven OpenTofu scaffold because CIDR and subnet layout can remain
  variable inputs rather than hardcoded decisions.

## Changes

- Replaced raw `terraform` examples in `platform/connectivity/global/00-dns-public/README.md` with Makefile commands.
- Added public DNS-specific affected scope, blast radius, rollback note, remaining risk, and registrar delegation human gate.
- Added `.codex/agent-runs/` to `.gitignore`.
- Expanded `platform/connectivity/kr/koreacentral/hub/00-hub-network/README.md` from a one-line scaffold into an implementation contract with scope, dependency direction, human gates, platform change requirements, and validation gap.
- Updated task history validation that was left pending after an interrupted turn.
- Expanded `platform/connectivity/kr/koreacentral/hub/05-private-dns/README.md` from a one-line scaffold into an implementation contract with scope, dependency direction, human gates, platform change requirements, and validation gap.
- Expanded `platform/connectivity/kr/koreacentral/hub/10-egress-routing-security/README.md` from a one-line scaffold into an implementation contract with scope, dependency direction, human gates, platform change requirements, and validation gap.
- Added OpenTofu files for
  `platform/connectivity/kr/koreacentral/hub/00-hub-network`:
  `backend.tf`, `versions.tf`, `providers.tf`, `locals.tf`, `variables.tf`,
  `main.tf`, `outputs.tf`, `backend.hcl.example`, `terraform.tfvars.example`,
  and `.terraform.lock.hcl`.
- Implemented only the safe scaffold: resource group, VNet, subnet map, tags,
  backend stub, examples, and downstream outputs.
- Kept hub CIDR and subnet layout as human-approved inputs instead of making
  architecture decisions in code.
- Updated the hub network README so validation now points to the real Makefile
  command.

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
- `make validate STACK=platform/connectivity/global/00-dns-public` passed with provider registry access.
- `npx prettier --write platform/connectivity/global/00-dns-public/README.md` completed.
- `npx prettier --write platform/connectivity/kr/koreacentral/hub/00-hub-network/README.md` completed.
- `npx prettier --write platform/connectivity/kr/koreacentral/hub/05-private-dns/README.md` completed.
- `npx prettier --write platform/connectivity/kr/koreacentral/hub/10-egress-routing-security/README.md` completed.
- `make fmt` passed.
- `make validate STACK=platform/connectivity/kr/koreacentral/hub/00-hub-network`
  first failed inside the sandbox because provider registry DNS was blocked.
- `make validate STACK=platform/connectivity/kr/koreacentral/hub/00-hub-network`
  passed with provider registry access.

## Next Step

- Review and approve the actual hub CIDR/subnet layout before running plan.
- After CIDR approval, run
  `make plan STACK=platform/connectivity/kr/koreacentral/hub/00-hub-network`.

## Risks

- This README change does not modify infrastructure code or state.
- The public DNS stack affects apex DNS and registrar delegation when applied; apply and registrar changes remain human decision gates.
- Hub network implementation decisions remain human gates; this task only changes documentation.
- Private DNS implementation decisions remain human gates; this task only changes documentation.
- Egress routing security implementation decisions remain human gates; this task only changes documentation.
- Hub network scaffold is now real infrastructure code, but plan/apply still
  depend on human-approved CIDR and subnet values.
- The agent workflow was closed with diff-review and postmortem bundles after
  implementation, instead of before implementation.
- Added a troubleshooting note for agent workflow drift into documentation-only
  loops.
- Added a learning entry for the difference between agent context bundles and
  implementation loops.

## Current Turn Update

Goal:

- Investigate why running `tofu apply` from a `hub` directory returned
  `Error: No configuration files`, and identify the safe repository command
  path.

Findings:

- The repository is multi-stack: `stacks/dev/kr/koreacentral/hub` is a grouping
  directory, not a state-owning OpenTofu stack.
- Actual dev hub stacks live under numbered child directories:
  `00-hub-network`, `05-private-dns`, `10-egress-routing-security`, and
  `20-access-ops`.
- The parent hub directory contains no `.tf` configuration files, so raw
  `tofu apply` there fails before planning.
- Repository policy prefers Makefile entrypoints, especially
  `make plan STACK=<stack-path>` and `make apply STACK=<stack-path>`.
- Dev hub stack directories currently have `backend.hcl.example` and
  `terraform.tfvars.example`, but no real `backend.hcl` or `terraform.tfvars`
  files.

Changes:

- No repository files were changed except this session note.

Validation:

- Read-only investigation only; no validation, plan, apply, backend migration,
  or state operation was run.

Next step:

## 2026-05-27 - Dev Hub Network Local Variables

Goal:

- Create a practical local `terraform.tfvars` for
  `stacks/dev/kr/koreacentral/hub/00-hub-network` and clarify how shared and
  stack-local variables are combined through the Makefile workflow.

Files read:

- `stacks/dev/kr/koreacentral/hub/00-hub-network/variables.tf`
- `stacks/dev/kr/koreacentral/hub/00-hub-network/terraform.tfvars.example`
- `stacks/dev/kr/koreacentral/hub/00-hub-network/README.md`
- `stacks/dev/kr/koreacentral/hub/00-hub-network/providers.tf`
- `stacks/dev/kr/koreacentral/hub/00-hub-network/locals.tf`
- `stacks/dev/kr/koreacentral/hub/00-hub-network/backend.tf`
- `stacks/dev/kr/koreacentral/hub/00-hub-network/outputs.tf`
- `Makefile`
- `.gitignore`

Findings:

- `platform/terraform.shared.tfvars` exists locally and is ignored by git.
- `stacks/dev/kr/koreacentral/hub/00-hub-network/terraform.tfvars` did not
  exist before this turn.
- The Makefile passes shared variables first and stack-local variables second:
  `-var-file=$(SHARED_VARS)` followed by `-var-file=terraform.tfvars`.
- Stack-local values override duplicate keys from shared vars if the same
  variable is defined in both places.
- Both real `*.tfvars` files are ignored by `.gitignore`; examples are tracked.

Changes:

- Added local
  `stacks/dev/kr/koreacentral/hub/00-hub-network/terraform.tfvars` with dev hub
  network values for `organization`, `environment`, `hub_address_space`,
  `hub_subnets`, `cost_center`, and `owner`.
- Did not modify `platform/terraform.shared.tfvars` because it already exists
  locally and may contain sensitive subscription or tenant identifiers.

Validation:

- `make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network` first
  failed in the sandbox because provider registry DNS was blocked.
- `make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network` passed
  with provider registry access.

Next step:

- Run `make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network`.
- After backend values and CIDR/subnet choices are confirmed, run
  `make plan STACK=stacks/dev/kr/koreacentral/hub/00-hub-network`.

Risks:

- The sample CIDR `10.0.0.0/20` and subnet `10.0.0.0/24` must be checked
  against any existing Azure, VPN, ExpressRoute, and on-premises address spaces
  before plan/apply.
- Applying this stack creates the dev Korea Central hub resource group, VNet,
  and subnet resources and can affect downstream hub and spoke design.

- Create/review real `backend.hcl` and `terraform.tfvars` for the first stack,
  then run `make plan STACK=stacks/dev/kr/koreacentral/hub/00-hub-network`.

Risks:

- Running raw `tofu apply` in a grouping directory bypasses repository guardrails
  and is not the intended workflow.
- Applying the hub network can affect downstream private DNS, egress routing,
  access operations, and future spokes.
- Real backend and variable files may contain environment-specific values and
  should not be committed if they contain sensitive or local configuration.

## 2026-05-16 - Hub VNet Learning Notes

Goal:

- Convert the hub VNet and Azure hub stack explanation into a durable learning
  file in the repository.

Files read:

- `docs/learning/inbox.md`
- `.codex/session-notes/current.md`
- `docs/task-history/`

Changes:

- Added `docs/learning/hub-vnet-learning-notes.md` with OpenTofu syntax,
  Azure VNet concepts, hub-spoke topology, dev hub stack responsibilities,
  state-boundary guidance, review questions, practice routines, interview
  drills, and official learning links.
- Added a short learning inbox entry pointing to the detailed hub VNet note.

Validation:

- Pending targeted Markdown formatting check.

Next step:

- Run Prettier check on the changed Markdown files.

Risks:

- Documentation-only change; no infrastructure, backend, state, or production
  behavior changed.
