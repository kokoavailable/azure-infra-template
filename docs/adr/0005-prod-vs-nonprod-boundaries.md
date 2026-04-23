# ADR 0005: Keep Production and Non-Production Boundaries Explicit

- Status: Accepted
- Date: 2026-04-09

## Context
Production environments have stricter reliability, security, and change-control requirements than development and staging environments. Treating all environments as equivalent tends to blur rollback expectations, access policy, and failure blast radius.

## Decision
Maintain explicit production versus non-production boundaries for stacks, access, rollout flow, and shared resource usage.

## Rationale
- Promotion paths are clearer when production is treated as a distinct boundary.
- Access and approval requirements can be stronger in production without slowing all development work.
- Shared services can be evaluated case by case instead of assuming universal reuse.

## Consequences
- Promotion paths are clearer and safer.
- Some duplication is accepted to reduce blast radius.
- Cost and operational trade-offs must be reviewed per shared service.
