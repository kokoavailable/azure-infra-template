# stacks/AGENTS.md

## Scope

This directory contains reusable stack templates, conventions, and safe composition patterns.

These files define how new stacks should be structured before stack-specific values are introduced elsewhere.

## Operating rules

Read root `AGENTS.md` first, then this file.

Templates must be generic.

Do not include real environment values.

Do not include real backend values.

Keep examples safe, fake, and clearly non-production.

Favor conventions that reduce review ambiguity across `platform/` and `spokes/`.

## Required template shape

A stack template should include:

- `README.md`
- `versions.tf`
- `providers.tf`
- `backend.tf`
- `backend.hcl.example`
- `locals.tf`
- `variables.tf`
- `main.tf`
- `outputs.tf`
- `terraform.tfvars.example`

## Design rules

Each template should make these expectations obvious:

- one stack owns one state
- backend config is externalized
- variable interface is explicit
- outputs are stable and intentional
- dependencies are documented
- no hidden environment assumptions

If template conventions change, update:

- `docs/stack-conventions.md`
- `docs/codex-workflow.md` when review workflow changes
- any related README guidance

## Review focus

Prioritize review of:

- accidental real values in examples
- undocumented required files
- missing variable or output guidance
- conventions that would encourage cyclic dependencies
- template choices that make unsafe apply behavior easier
