# DNS Strategy

## Goals
DNS should provide clear ownership, predictable resolution paths, and minimal duplication across environments.

## Fixed principles (Stage 0)
| Concern | Principle |
| --- | --- |
| Public DNS | **Global** platform ownership — internet-facing zones and records live under `platform/connectivity/global/` (for example `00-dns-public`). |
| Private DNS | **Hub-centric** — private DNS zones that serve Azure PaaS private endpoints and internal names are anchored from the hub design; spokes **link** to zones and consume resolution accordingly. |
| Private endpoints | Provisioned in the **spoke** next to the service; **zone association and DNS update policy** follow the hub-aligned model so resolution stays consistent across spokes. |

This aligns with `adr/0004-private-dns-centralization.md`.

## Design Principles
- Separate public and private DNS ownership.
- Keep internet-facing records under shared platform governance.
- Centralize shared private endpoint namespaces to avoid duplicate zones and conflicting records.
- Treat DNS changes as production-grade rollout events with validation and rollback steps.

## Public DNS
- Centralize internet-facing zones under shared platform ownership (global stack).
- Keep records for edge entry points versioned in infrastructure code.
- Use low TTLs only where rapid rollback or cutover is required.
- Document record ownership when multiple workloads share the same public zone.

## Private DNS
- Manage private zones from the **hub connectivity** perspective: zone lifecycle, linkage rules, and which VNets may participate.
- Link workload VNets explicitly to approved zones (spoke VNet links registered consistently).
- Avoid each workload creating its own duplicate private zone for the same Azure private endpoint namespace.
- Document who owns zone creation, VNet linking, and resolver configuration.

## Resolution Model
- Public clients resolve only public zones.
- Workload VNets resolve private zones through hub-approved zone links (and Azure-provided resolver behavior inside linked VNets).
- Hybrid name resolution should be documented whenever on-premises or external resolvers participate.
- Resolver or forwarding dependencies should be explicit so incident responders know where to look during failures.

## Operational Rules
- Document every delegated zone, conditional forwarder, and resolver dependency.
- Review DNS changes with the same care as ingress or certificate changes.
- Validate resolution from the relevant client network (spoke subnets and hub inspection paths), not only from an operator workstation.
- Keep rollback records or previous targets available for critical cutovers.
