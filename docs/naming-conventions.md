# Naming Conventions

## Goals
Resource names should be predictable, sortable, and short enough to satisfy Azure naming limits while still communicating ownership and purpose.

## Canonical Pattern
Use the following logical pattern where service-specific limits allow it:

`<org>-<env>-<region>-<workload>-<component>-<instance>`

Example:

`acme-prod-krc-web-agw-01`

## Segment Guidance
- `org`: short organization or platform prefix
- `env`: lifecycle stage such as `dev`, `stg`, or `prod`
- `region`: approved short region code such as `krc` for `koreacentral`
- `workload`: workload, service, or platform domain name
- `component`: short service abbreviation such as `agw`, `vmss`, `pg`, `kv`, or `st`
- `instance`: numeric suffix when multiple instances of the same component exist

## Naming Rules
- Use lowercase letters, numbers, and hyphens unless a resource type requires another format.
- Do not encode ticket numbers, personal initials, or temporary project labels into resource names.
- Keep names stable across refactors so monitoring, dashboards, and runbooks remain readable.
- Prefer the same abbreviations across modules, stacks, dashboards, and tags.
- Choose names that remain valid when a resource is promoted from non-production patterns into production patterns.

## Azure-Specific Notes
- Some Azure services have global uniqueness constraints or shorter maximum lengths.
- Some services do not allow hyphens, uppercase letters, or certain suffixes.
- When a service-specific rule conflicts with the canonical pattern, keep the same segment meaning even if separators or truncation change.

## Recommended Abbreviations
Use consistent abbreviations for common components:
- `agw`: Application Gateway
- `vmss`: Virtual Machine Scale Set
- `vm`: Virtual Machine
- `pg`: PostgreSQL
- `kv`: Key Vault
- `st`: Storage
- `la`: Log Analytics
- `pe`: Private Endpoint
- `dns`: DNS

## Region Codes
Maintain an approved list of short region codes and use them consistently across all stacks. Example mappings:
- `krc`: `koreacentral`
- `krs`: `koreasouth`
- `eus`: `eastus`

## Tagging Baseline
Every managed resource should carry, at minimum:
- `environment`
- `region`
- `workload`
- `owner`
- `cost_center`
- `managed_by=iac`

## Tagging Guidance
- Tags should reflect ownership and operational routing, not just cost allocation.
- Required tags should be enforced through modules, stack locals, or policy where possible.
- Avoid free-form tags when a controlled value list exists.
