# Project Roadmap

## Purpose

This roadmap defines the path to complete this Azure infrastructure platform
template. It is the project-level goal map, not a release procedure.

Use this document to decide what to work on next, what "done" means for each
phase, and which validation gates must pass before moving forward.

## Operating Principle

Progress in this order:

```text
documentation and workflow
safe command interface
remote state bootstrap
platform foundation
GitHub OIDC and CI
dev spoke vertical slice
reference workload
staging and production hardening
```

Do not start with production. Prove the workflow on a narrow, reviewable dev
vertical slice first.

## Phase 1: Repository Operating System

Goal: make human and Codex collaboration restart-safe, reviewable, and
documented.

Tasks:

- Keep `AGENTS.md` and scoped `AGENTS.md` files aligned.
- Keep `.codex/prompts/` aligned with the role workflow.
- Keep Makefile `agent-*` targets aligned with reusable prompt workflows.
- Use `make agent-operating-loop` to route ambiguous work into automation and
  human judgment gates.
- Maintain `.codex/session-notes/current.md` for non-trivial work.
- Maintain `docs/task-history/` for completed task chronology.
- Use `docs/troubleshooting/` for recurring failures and recovery patterns.
- Use `docs/learning/inbox.md` only for concepts the user actually struggled
  with.
- Fix or document limitations in documentation formatting workflows.

Done when:

- Codex can resume from session notes after interruption.
- Completed tasks have concise history entries.
- Agent workflow prompts can be rendered through Makefile targets.
- Ambiguous work can be converted into a reviewed operating loop before edits.
- Documentation and prompt updates have targeted formatting checks.
- Troubleshooting notes exist for recurring workflow failures.

Validation:

```bash
npx prettier --check <changed-doc-files>
git status --short
git diff --stat
```

## Phase 2: Makefile Safety Interface

Goal: make the Makefile the safe operator interface for local and CI work.

Tasks:

- Verify `make fmt`.
- Verify `make docs-fmt` or document/fix known blockers.
- Verify `make init STACK=<stack-path>`.
- Verify `make validate STACK=<stack-path>`.
- Verify `make plan STACK=<stack-path>` only with expected credentials and
  backend access.
- Verify `make check STACK=<stack-path>`.

Done when:

- Safe commands behave predictably.
- Raw `tofu` usage is unnecessary for normal validation.
- Any unsafe or blocked command has a troubleshooting note.

Validation:

```bash
make fmt
make docs-fmt
make validate STACK=<sample-stack>
```

## Phase 3: Bootstrap State Workflow

Goal: make remote state creation repeatable without committing sensitive backend
values.

Tasks:

- Inspect `scripts/bootstrap/`.
- Confirm backend storage naming conventions.
- Keep real `backend.hcl` files out of version control.
- Maintain `backend.hcl.example` files where needed.
- Document bootstrap inputs and operator prerequisites.
- Document rollback or recovery paths for failed bootstrap attempts.

Done when:

- A new environment can bootstrap remote state from documented inputs.
- Backend configuration remains externalized.
- State migration is not implied or automated accidentally.

Validation:

```bash
git status --short
rg -n "tenant_id|subscription_id|client_secret|terraform.tfstate|backend.hcl" .
```

## Phase 4: Platform Foundation

Goal: validate shared platform layers before workload stacks consume them.

Preferred order:

```text
platform/management
platform/identity
platform/connectivity
platform/shared-services/nonprod
platform/shared-services/prod
```

Tasks:

- Validate stack variables and outputs.
- Confirm backend state boundaries.
- Confirm downstream-only remote-state dependencies.
- Review RBAC scopes.
- Review DNS blast radius.
- Update stack READMEs with validation commands and rollback notes.

Done when:

- Each platform stack has one clear state owner.
- Downstream stacks consume outputs without reverse dependencies.
- High-risk platform changes include blast radius, rollback, validation, and
  remaining risk notes.

Validation:

```bash
make fmt
make validate STACK=<platform-stack-path>
```

## Phase 5: GitHub OIDC and CI

Goal: allow GitHub Actions to authenticate to Azure without long-lived secrets.

Tasks:

- Define federated credential scope by repo, environment, and branch policy.
- Keep Azure role assignment scopes minimal.
- Separate pull request validation from apply workflows.
- Add approval gates for protected environments.
- Document CI failure diagnosis and recovery.

Done when:

- PR workflows validate and plan without client secrets.
- Apply workflows require explicit approval.
- Production deployment cannot happen accidentally.

Validation:

```bash
gh workflow list
gh run list --limit 10
```

Use GitHub CLI commands only when credentials are available.

## Phase 6: Dev Spoke Vertical Slice

Goal: prove one workload path end to end in `dev` before touching `stg` or
`prod`.

Preferred order:

```text
spokes/dev/.../00-spoke-network
spokes/dev/.../05-secrets
spokes/dev/.../06-configuration
spokes/dev/.../20-data
spokes/dev/.../25-utility-access
spokes/dev/.../30-compute
spokes/dev/.../10-edge
spokes/dev/.../40-observability
```

Tasks:

- Start with dev only.
- Validate network, private DNS, Key Vault, configuration, data, compute, edge,
  and observability dependency flow.
- Keep utility access separate from runtime compute.
- Update stack READMEs as interfaces become real.

Done when:

- Dev spoke dependencies are explicit and acyclic.
- Each dev stack validates independently.
- The path from network to observability is documented and reviewable.

Validation:

```bash
make validate STACK=spokes/dev/<spoke>/kr/koreacentral/<stack>
```

## Phase 7: Reference Workload

Goal: prove the template can support a real workload lifecycle.

Tasks:

- Define a minimal reference runtime.
- Validate image build and promotion assumptions.
- Connect compute to health probes.
- Connect edge routing to the workload.
- Capture logs, metrics, and alerts.
- Document rollback through image version or stack input.

Done when:

- A dev reference workload can be deployed, verified, observed, and rolled back.
- Runtime and utility access stay separate.
- Promotion evidence is clear enough for review.

Validation:

```bash
make validate STACK=<reference-workload-stack>
```

Plan or apply only through approved workflows and explicit user approval.

## Phase 8: Staging and Production Hardening

Goal: promote proven patterns from dev into staging and production with stricter
controls.

Tasks:

- Replicate validated patterns into `stg`.
- Keep production inputs separate.
- Minimize production RBAC.
- Require protected environment approvals.
- Document DNS and certificate lifecycle.
- Confirm backup, restore, monitoring, alerting, and rollback expectations.

Done when:

- Production changes require explicit approval, reviewed plans, validation
  evidence, and rollback notes.
- Staging proves the release path before production.
- Production shared services and workload stacks have documented blast radius.

Validation:

```bash
make validate STACK=<stg-or-prod-stack>
```

Run plans only when credentials and backend access are appropriate and the user
expects a plan.

## Current Next Tasks

1. Fix or intentionally scope `make docs-fmt` so documentation formatting is
   reliable.
2. Verify the Makefile safety interface.
3. Inspect the bootstrap state workflow.
4. Validate the first platform stack.
5. Complete GitHub OIDC and CI validation.
6. Start the dev spoke vertical slice.

## Review Questions

Use these before starting a new task:

- Which phase does this task belong to?
- What is the smallest stack, module, or document boundary that can change?
- What validation proves the change?
- Does this expose a recurring failure that belongs in `docs/troubleshooting/`?
- Did the user struggle with a concept that belongs in `docs/learning/inbox.md`?
- Is this asking Codex to assist, or asking Codex to make a judgment humans
  must own?
