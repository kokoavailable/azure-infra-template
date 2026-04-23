# Layer Dependency

## Purpose
This document defines the recommended deployment order for infrastructure layers and the dependency rules that keep stacks understandable, reviewable, and loosely coupled.

## Repository apply order (platform → spokes)
Before workload stacks, apply shared platform state in this order unless an ADR documents an exception:

1. **Identity / governance** (as needed): `platform/identity/`, `platform/management/`.
2. **Global connectivity**: `platform/connectivity/global/` (public DNS and other global primitives).
3. **Regional hub**: `platform/connectivity/<region-code>/<azure-region>/hub/` — hub network, private DNS posture, egress/security, shared access paths.
4. **Shared services**: `platform/shared-services/nonprod/` and/or `platform/shared-services/prod/` depending on scope.
5. **Spokes**: `spokes/<env>/<spoke-name>/<region-code>/<azure-region>/` — see canonical layer numbers in `stack-conventions.md`.

Cross-environment rule of thumb: establish or update **patterns** in non-production first when the change affects shared modules, addressing, or hub routing.

## Why Layering Exists
Layering is used to:
- Reduce circular dependencies between stacks.
- Make plans easier to review by limiting the scope of each stack.
- Allow earlier layers to publish stable outputs for later layers.
- Support safe promotion from non-production to production with fewer hidden assumptions.

## Canonical Order (within a spoke or single state)
Apply layers in the following order unless a documented exception exists:

1. `foundation`
2. `secrets`
3. `configuration`
4. `edge`
5. `data`
6. `compute`
7. `observability`

Directory prefixes used in this repo map roughly as: `00-*` foundation/network, `05-*` secrets, `06-*` configuration, `10-*` edge, `20-*` data, `30-*` compute, `40-*` observability.

## Layer Responsibilities

### `foundation`
Owns the base resources that later layers rely on, such as:
- Resource groups
- Virtual networks and subnets
- Shared identities or identity scaffolding
- Common tagging, naming inputs, and baseline policy attachments

This layer should avoid workload-specific logic whenever possible.

### `secrets`
Owns secret storage and secret distribution primitives, such as:
- Key Vault instances
- Secret containers and secret metadata
- Certificate containers and issuance wiring
- Access policies or RBAC assignments needed for secret consumers

This layer should establish the secret boundary before runtime services begin consuming secrets.

### `configuration`
Owns configuration inputs that compute and application layers consume, such as:
- Application configuration values
- Shared feature flags or environment settings
- Bootstrap metadata needed by startup scripts or extensions

Configuration should be versioned and explicit rather than embedded in ad hoc scripts.

### `edge`
Owns public-facing and traffic-management components **for the workload**, such as:
- Spoke-owned Application Gateway / WAF and workload ingress
- Certificates and listener bindings tied to the application

**Note:** Central egress, hub firewall routing, and shared ops ingress patterns are platform/hub concerns; see `architecture.md` and `security-baseline.md`.

Edge should depend only on earlier layers and should not create deep coupling back into compute internals.

### `data`
Owns stateful managed services, such as:
- Databases
- Storage accounts and containers
- Backup or retention resources
- Private connectivity for stateful dependencies

Data should be provisioned before compute so workloads can be attached deterministically.

### `compute`
Owns runtime execution resources, such as:
- VM Scale Sets
- Utility or operational virtual machines
- Autoscale rules
- Extensions, boot-time configuration, and image references

Compute should consume approved images and stable outputs from prior layers.

### `observability`
Owns monitoring and operational visibility resources, such as:
- Diagnostic settings
- Log routing and workspace wiring
- Alerts, action groups, and dashboards
- Health and SLO/SLA-related visibility artifacts

Although observability is listed last, baseline diagnostics may also appear in earlier layers when a resource must self-publish logs at creation time.

## Dependency Rules
- A layer may depend only on outputs from earlier layers.
- A later layer must not be required to complete an earlier layer's plan or apply.
- Cross-region dependencies should be explicit and justified.
- Cross-environment dependencies should be rare and documented.
- Shared platform services should be consumed through stable outputs, not by rediscovering resources through naming conventions alone.
- Circular dependencies must be resolved by moving shared concerns into an earlier layer or by splitting stack responsibilities.

## Anti-Patterns
Avoid the following:
- Creating a database inside a compute stack because it is convenient for one workload.
- Having edge stacks read instance IDs or other short-lived compute implementation details.
- Re-querying resource names across stacks when an output already exists.
- Combining unrelated layers in a single state file just to reduce the number of applies.

## Apply Guidance
- Apply shared platform stacks before workload stacks.
- Apply global or central stacks before regional stacks.
- Apply non-production before production when the change affects shared patterns, images, or core modules.
- Treat major layer reordering as an architectural change that should be captured in an ADR.
