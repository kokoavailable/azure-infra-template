# ADR 0001: Split Platform and Workloads

- Status: Accepted
- Date: 2026-04-09

## Context
Shared services such as DNS, identity federation, governance, and central observability change at a different cadence than application-facing stacks. When shared and workload-specific resources are managed together, review scope becomes larger, deployment risk increases, and ownership becomes unclear.

## Decision
Separate shared platform stacks from workload stacks in both the repository structure and the deployment model.

## Rationale
- Shared services have broader blast radius and require stricter change control.
- Workload stacks should be able to evolve without forcing unrelated platform changes into the same plan.
- Platform outputs can become stable contracts that workloads consume explicitly.

## Consequences
- Shared services can evolve independently from application-facing stacks.
- Workload changes have a smaller blast radius and easier review scope.
- Cross-boundary outputs and dependencies must be modeled deliberately.
- Some duplication of structure is acceptable in exchange for clearer ownership.
