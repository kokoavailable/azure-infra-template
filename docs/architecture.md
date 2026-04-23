# Architecture

## Purpose
This document describes the target architecture for the Azure infrastructure repository. It explains how infrastructure code is organized, how changes move through the control plane, and how runtime services are composed in the data plane.

## Stage 0: design-first decisions (fixed before heavy provisioning)
Landing-zone style repos should fix **addressing, environment boundaries, deployment principles, and DNS / Private Link posture** in documentation and variable schemes before creating most resources. Stage 0 outputs are primarily **documents and conventions**, not large Terraform applies.

The following choices are **locked for this repository** unless superseded by an ADR:

| Topic | Decision |
| --- | --- |
| Environments | `dev`, `stg`, `prod` |
| Region (initial) | Korea Central (`koreacentral`); directory layout uses `kr/koreacentral/` under regional paths |
| Hubs per region | **One** hub virtual network per region (single regional connectivity anchor) |
| Spoke boundaries | Workload-oriented spokes such as `app-main`, `shared-airflow`, `shared-observability` — each owns its network slice and workload stacks |
| Network plan | Non-overlapping RFC1918 ranges; hub and each spoke receive dedicated reservations (see below) |
| Public DNS | **Global** platform ownership (`platform/connectivity/global/`) |
| Private DNS | **Hub-centric**: zones and resolution posture owned from the hub; spokes link/consume per strategy |
| Private endpoints | Created in the **spoke** where the service lives; **DNS registration and private zone linkage** follow the hub-aligned model in `dns-strategy.md` |
| Ingress | Per-app **Application Gateway + WAF** (and related edge objects) live in the **spoke** |
| Egress / central security | **Azure Firewall**, forced tunnel / route intent, **NAT** where applicable, **Bastion** or shared ops access patterns live in the **hub** (or hub-owned stacks) |

### Network CIDR reservation (initial plan)
Ranges are illustrative until allocated in IPAM; the **rules** are: no overlap between hub and spokes, no overlap across spokes, and reserve space for growth within each spoke.

| Scope | Example reservation | Notes |
| --- | --- | --- |
| Hub (Korea Central) | `10.200.0.0/16` | Firewall, Bastion, gateway subnets, shared DMZ patterns as designed |
| Spoke `dev` / `app-main` | `10.210.0.0/16` | Dev workload; subdivide into subnets per layer |
| Spoke `stg` / `app-main` | `10.211.0.0/16` | Staging |
| Spoke `prod` / `app-main` | `10.212.0.0/16` | Production app |
| Spoke `*` / `shared-observability` | `10.213.0.0/16` | Slice per env under `spokes/<env>/shared-observability/` |
| Spoke `*` / `shared-airflow` | `10.214.0.0/16` | Slice per env |

Adjust numbers in IPAM; keep **documentation and Terraform locals** in sync when values change.

### Repository layout (regions and paths)
- Platform connectivity: `platform/connectivity/global/…` (public DNS) and `platform/connectivity/kr/koreacentral/hub/…` (hub network, private DNS posture, egress, shared access).
- Platform shared services: `platform/shared-services/<nonprod|prod>/…`.
- Workloads: `spokes/<env>/<spoke-name>/kr/koreacentral/…`.

See `stack-conventions.md` for stack numbering and folder naming. For a full ASCII tree (including scaffold vs future `.tf` files), see `readme2.md` at the repository root.

## Architectural Goals
- Keep shared platform services separate from application-facing workload stacks.
- Prefer private and explicitly governed connectivity for management and data paths.
- Build immutable compute artifacts and promote them through controlled rollout stages.
- Keep naming, deployment order, and operational policy visible in version-controlled documentation.
- Design for regional growth without forcing every workload to manage shared concerns independently.

## Scope
This repository is intended to manage:
- Shared platform capabilities such as identity federation, DNS, governance, and common networking primitives.
- Reusable infrastructure modules for Azure services.
- Environment-specific workload stacks for non-production and production deployment targets.
- Build and release workflows for both infrastructure changes and golden machine images.

This repository is not intended to replace application source code repositories or application deployment manifests beyond the infrastructure concerns that support them.

## Control Plane
The control plane governs how infrastructure changes are proposed, validated, approved, and applied.

### Main Components
- GitHub repositories, pull requests, and branch protection as the source of review and approval.
- GitHub Actions workflows for formatting, validation, planning, applying, image build, and documentation checks.
- Terraform as the primary infrastructure-as-code engine for Azure resource provisioning (CLI version in `.terraform-version`; provider pins in each stack `versions.tf`).
- Packer for producing hardened base images that are later consumed by compute stacks.
- GitHub OIDC federation for short-lived CI authentication to Azure without storing long-lived credentials.
- Policy and governance controls that constrain what can be deployed and how.

### Control Plane Flow
1. A contributor proposes a change in a branch.
2. CI runs formatting, validation, documentation, and planning checks.
3. Reviewers inspect both the code diff and infrastructure plan.
4. Approved changes are applied through controlled workflows.
5. Post-apply telemetry and health checks confirm whether the change is healthy.

## Data Plane
The data plane contains the resources that serve live workloads and operational users.

### Core Building Blocks
- Edge services such as public DNS, WAF, and L7/L4 entry points.
- Virtual networks, subnets, routing controls, NSGs, and private connectivity.
- Compute services such as VM Scale Sets, maintenance hosts, and utility VMs.
- Data services such as Key Vault, managed databases, storage, and backup targets.
- Observability services such as logs, metrics, traces, alerts, and dashboards.

### Design Expectations
- Stateful services should prefer private endpoints or private network access where supported.
- Compute should be image-driven instead of relying on large mutable bootstrap steps.
- Shared infrastructure should expose stable outputs rather than forcing downstream stacks to rediscover resources by name.
- Every deployed component should integrate with the observability and security baseline.

## Platform and Workload Boundaries
The repository intentionally distinguishes between platform and workload concerns.

### Platform Layer
The platform layer owns shared capabilities that many workloads consume, including:
- Identity federation and CI authentication setup.
- Central DNS ownership and shared resolution paths.
- Shared governance, policy, and baseline monitoring.
- Network primitives or services that need a single point of ownership.

### Workload Layer
Workload stacks own application-facing resources, including:
- Region- and environment-specific networking.
- Compute and data services needed by a single application or bounded service group.
- Per-environment configuration and release inputs.
- Workload-specific observability and access rules within the platform baseline.

## Environment Model
Environments are separated where risk, access control, and operational policy require it.

Key expectations:
- **dev** / **stg** / **prod** are distinct control and network boundaries; see `adr/0005-prod-vs-nonprod-boundaries.md`.
- Non-production environments are used for iteration, validation, and image promotion.
- Production environments are isolated more strictly for reliability and change control.
- Shared services may span multiple environments only when their blast radius is understood and accepted.
- Cross-environment dependencies should be rare, explicit, and documented.

## Regional Model
The repository should support one or more Azure regions without changing the ownership model.

Regional design principles:
- Global services are managed independently from region-specific workload resources.
- Initial regional anchor: **one hub per region** (Korea Central first).
- Regional stacks should be repeatable with parameterized inputs, not copied by hand.
- Disaster recovery or active/active designs should be documented at the workload level when required.

## Hub–Spoke Connectivity (conceptual)
- **Hub** concentrates shared egress, inbound ops paths, and private DNS policy for the design.
- **Spokes** attach workload VNets; workload ingress (App Gateway/WAF) and workload-scoped resources stay in the spoke.
- Peering or equivalent connectivity follows Azure landing zone patterns with explicit routing to the hub firewall when egress inspection is required.

## High-Level Dependency View
The intended logical flow is:
1. Shared platform prerequisites are created first.
2. Hub connectivity and private DNS posture are established.
3. Spoke networks and security/configuration dependencies are established.
4. Stateful services are provisioned before compute is attached.
5. Compute is rolled out using approved images and explicit health checks.
6. Observability, alerting, and operational checks complete the stack.

Detailed layer ordering is described in `layer-dependency.md`.

## Operational Implications
- Changes to shared services require tighter review because they affect more than one workload.
- Compute changes should prefer artifact promotion over in-place mutation.
- Rollbacks should rely on previous image versions, stable inputs, or reversible infrastructure plans where possible.
- Documentation is part of the architecture contract, not a post-deployment afterthought.

## Related Documents
- `layer-dependency.md` defines deployment order and allowed dependencies.
- `stack-conventions.md` defines the expected file layout inside each stack and repository paths.
- `release-strategy.md` defines artifact promotion, rollout, and rollback behavior.
- `dns-strategy.md` defines public and private name-resolution ownership.
- `security-baseline.md` defines the minimum security requirements for all stacks.
