# ADR 0003: Publish Golden Images Through Azure Compute Gallery

- Status: Accepted
- Date: 2026-04-09

## Context
Compute stacks need a repeatable way to distribute approved base images across environments and regions without rebuilding ad hoc. Rebuilding images per environment increases drift risk and weakens confidence that the same tested artifact reached production.

## Decision
Build hardened images with Packer and publish approved versions through Azure Compute Gallery.

## Rationale
- A shared image publication path supports artifact promotion instead of per-environment rebuilds.
- Approved image versions remain addressable for rollback.
- Image versioning becomes visible and reviewable as part of the release process.

## Consequences
- Compute rollouts can promote a stable image artifact through multiple environments.
- Rollback is simpler because previous image versions remain addressable.
- Image lifecycle management, retention, and deprecation become first-class operational concerns.
