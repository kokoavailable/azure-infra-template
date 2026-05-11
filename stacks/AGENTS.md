# stacks/AGENTS.md

## Scope

This directory contains deployed environment stacks.

Path model:

- `stacks/dev/kr/koreacentral/hub/...`
- `stacks/dev/kr/koreacentral/spokes/<spoke-name>/...`
- `stacks/stg/kr/koreacentral/hub/...`
- `stacks/stg/kr/koreacentral/spokes/<spoke-name>/...`
- `stacks/prod/kr/koreacentral/hub/...`
- `stacks/prod/kr/koreacentral/spokes/<spoke-name>/...`

## Operating rules

Read root `AGENTS.md` first, then this file.

Start with `dev`.

Do not modify `prod` unless explicitly requested.

One PR should usually affect one environment and one hub or spoke boundary.

Do not modify dev, stg, and prod together unless the task explicitly requires cross-environment alignment.

## Preferred implementation order inside each environment

1. `hub/00-hub-network`
2. `hub/05-private-dns`
3. `hub/10-egress-routing-security`
4. `hub/20-access-ops`
5. `spokes/<spoke-name>/00-spoke-network`
6. `spokes/<spoke-name>/05-secrets`
7. `spokes/<spoke-name>/06-configuration`
8. `spokes/<spoke-name>/20-data`
9. `spokes/<spoke-name>/25-utility-access`
10. `spokes/<spoke-name>/30-compute`
11. `spokes/<spoke-name>/10-edge`
12. `spokes/<spoke-name>/40-observability`

## Dependency rules

Cross-stack dependencies must flow downstream only.

Typical direction inside an environment:

- hub network -> hub private DNS / egress / access operations
- hub outputs -> spoke networks
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
- platform-to-environment reverse state ownership
- hub stacks depending on spoke state

## Change requirements

Each environment stack change should state:

- environment
- hub or spoke name
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
