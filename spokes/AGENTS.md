# spokes/AGENTS.md

## Scope

This directory contains workload-specific spoke environments.

Path model:

- `spokes/dev/<spoke-name>/kr/koreacentral/...`
- `spokes/stg/<spoke-name>/kr/koreacentral/...`
- `spokes/prod/<spoke-name>/kr/koreacentral/...`

## Operating rules

Read root `AGENTS.md` first, then this file.

Start with `dev`.

Do not modify `prod` unless explicitly requested.

One PR should usually affect one environment and one spoke boundary.

Do not modify dev, stg, and prod together unless the task explicitly requires cross-environment alignment.

## Preferred implementation order

1. `00-spoke-network`
2. `05-secrets`
3. `06-configuration`
4. `20-data`
5. `25-utility-access`
6. `30-compute`
7. `10-edge`
8. `40-observability`

## Dependency rules

Cross-stack dependencies must flow downstream only.

Typical direction inside a spoke:

- network -> secrets/configuration
- secrets/configuration -> data
- network/data -> utility-access when operator access is required
- data -> compute
- compute -> observability
- edge depends on underlying network and workload targets

Do not introduce:

- cyclic remote-state dependencies
- implicit dependencies based only on naming
- cross-environment spoke coupling unless explicitly documented
- spoke-to-platform reverse ownership

## Change requirements

Each spoke change should state:

- environment
- spoke name
- affected stack path
- upstream dependency path
- validation command
- rollback note
- remaining risk

## Review focus

Prioritize review of:

- environment isolation
- secret handling
- private endpoint and DNS assumptions
- workload ingress exposure
- data-before-compute ordering
- prod scope creep
