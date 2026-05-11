# Stack Conventions

## Purpose

Each stack directory should follow a predictable layout so contributors can review changes quickly, understand ownership, and avoid hidden dependencies.

## Repository layout (canonical)

Stage 0 fixes the directory contract. Deployed stack instances, platform paths,
and templates follow the tree below (regions use `kr/koreacentral/` for the
first region).

```
platform/connectivity/global/…                # e.g. public DNS
platform/shared-services/<nonprod|prod>/…
stacks/<env>/kr/koreacentral/hub/…
stacks/<env>/kr/koreacentral/spokes/<spoke-name>/…
templates/_stack-template/…
```

- **env**: `dev` | `stg` | `prod`
- **spoke-name**: workload boundary such as `app-main`, `shared-airflow`,
  `shared-observability`

The top-level `stacks/` directory contains deployed stack instances. Reusable
scaffolds live under `templates/`.

Environment hub and spoke stacks use numeric prefixes for ordering:

| Prefix | Layer                             |
| ------ | --------------------------------- |
| `00-`  | Hub or spoke network / foundation |
| `05-`  | Secrets                           |
| `06-`  | Configuration                     |
| `10-`  | Edge (App Gateway / WAF in spoke) |
| `20-`  | Data                              |
| `25-`  | Utility access / operator hosts   |
| `30-`  | Compute                           |
| `40-`  | Observability                     |

Not every spoke includes every layer (for example, some stacks omit `40-observability` where not required).

Utility access stacks are separate from runtime compute. A `25-utility-access` stack may own operator-facing VMs or access helpers, while `30-compute` owns application runtime resources such as VM Scale Sets. Do not combine mutable utility hosts and application runtime compute in the same state unless an ADR explicitly supersedes this rule.

## Recommended Files

- `versions.tf`: Terraform and provider constraints; pin versions in each stack. Root **`.terraform-version`** sets the expected CLI (e.g. for tfenv).
- `providers.tf`: provider configuration and aliases when needed
- `backend.tf`: remote state backend configuration, if managed in-stack
- `locals.tf`: derived values, common tags, and naming helpers
- `variables.tf`: input interface and validation rules
- `main.tf`: primary composition entry point
- `outputs.tf`: stable values exported to downstream stacks
- `README.md`: stack purpose, inputs, outputs, and run-order notes

## Layout Principles

- One stack should own one clear unit of state.
- Keep resource files grouped by responsibility when a stack becomes large.
- Prefer module composition over duplicating raw resource definitions across environments.
- Keep output names stable, descriptive, and intentionally scoped.
- Document non-obvious ordering constraints in the stack README.

## File Organization Guidance

When a stack grows beyond a few resources, split files by responsibility, for example:

- `network.tf`
- `identity.tf`
- `diagnostics.tf`
- `role_assignments.tf`

Do not split files purely to make the directory look symmetrical. Split when it improves readability or ownership clarity.

## Variable Guidelines

- Define every externally supplied value in `variables.tf`.
- Add validation blocks where incorrect values can be detected early.
- Avoid variables that simply mirror a provider default unless that default is intentionally part of the contract.
- Prefer typed objects for related settings over long lists of loosely related scalar variables.

## Output Guidelines

- Export only the values that downstream stacks actually need.
- Keep outputs stable so refactors do not break consumers unnecessarily.
- Avoid exposing provider-internal details when a more meaningful output can be returned.

## State and Dependencies

- Cross-stack references should flow through outputs and deliberate remote-state lookups.
- Do not create hidden dependencies based on naming conventions alone.
- Do not read from unrelated stacks just because a resource happens to exist.
- If two stacks always need to be planned and applied together, revisit the boundary.

## Environment Structure

Use directory structure and inputs to separate:

- platform versus deployed environment concerns (`platform/` vs `stacks/`)
- global versus regional resources (`platform/connectivity/global/` vs
  `stacks/<env>/kr/koreacentral/hub/`)
- non-production versus production environments (`stacks/dev/`, `stacks/stg/`,
  `stacks/prod/`, and `platform/shared-services/<nonprod|prod>/`)
- reusable templates versus deployed stack instances (`templates/` vs
  `stacks/`)

The same stack pattern should remain recognizable across environments even when values differ.

## Documentation Expectations

Every stack README should explain:

- What the stack owns
- Which layers or stacks it depends on
- Which downstream stacks consume its outputs
- Any manual prerequisites, rollout notes, or rollback considerations
