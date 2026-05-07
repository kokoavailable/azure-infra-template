# ADR 0006: Separate Utility Access from Runtime Compute

- Status: Accepted
- Date: 2026-05-07

## Context

Development environments often need a mutable host for private troubleshooting, one-off scripts, migrations, or administrative tools. That host is operationally useful, but it has a different lifecycle from application runtime infrastructure.

The workload runtime target for this repository remains VMSS-based compute with explicit health, image, rollout, and rollback contracts. Mixing mutable utility access and runtime compute in the same stack would couple unrelated replacement risks and make promotion to staging and production less clear.

## Decision

Separate utility access hosts from application runtime compute.

For `dev`, a utility VM may be exposed through a tightly restricted public IP when hub-managed private access is not yet available. This is a documented non-production exception for operator convenience, not the workload runtime pattern.

For `stg` and `prod`, utility access must use private administration paths such as Bastion, VPN, or hub-owned operations access. Direct public IP access to utility hosts is not part of the target pattern.

Application runtime compute is owned by the `30-compute` layer and should use the VMSS model defined in ADR 0002 when VMSS fits the workload. Utility access is owned by a separate `25-utility-access` layer and state boundary.

## Rationale

- Utility hosts are mutable and operator-oriented; runtime compute should be reproducible and image-driven.
- Separate state boundaries reduce accidental replacement or deletion risk for application runtime resources.
- Dev can stay practical and low-cost without weakening the staging and production topology.
- Promotion remains clear: runtime patterns promote from dev to stg to prod, while dev-only utility exceptions do not.

## Consequences

- Dev may have a public utility access path, but it must be source-restricted and documented as an exception.
- `25-utility-access` depends on spoke networking and may consume secrets/configuration only when required.
- `30-compute` must not depend on mutable utility VM state.
- Staging and production require a private operations access pattern before utility hosts are introduced.
