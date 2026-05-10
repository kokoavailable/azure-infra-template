# 00-hub-network

Hub virtual network, peering integration points, and hub subnets for Korea
Central.

This stack is currently a scaffold. It documents the intended ownership boundary
for the regional hub network before OpenTofu resources are added.

## Intended scope

This stack should own:

- Korea Central hub virtual network
- hub subnets for shared connectivity services
- subnet reservations for Azure Firewall, Bastion, gateways, and shared
  operations access
- future spoke peering integration points when explicitly designed
- outputs consumed by downstream hub services and spoke network stacks

This stack should not own:

- public DNS zones
- private DNS zone lifecycle
- workload spoke VNets
- workload edge resources
- application runtime compute
- production-only shared services

## Dependency direction

Allowed direction:

```text
platform/connectivity/kr/koreacentral/hub/00-hub-network
-> downstream hub stacks
-> spoke network stacks
```

Do not introduce dependencies from this stack back into spokes.

## Human decision gates

The following require explicit human approval before implementation or apply:

- hub CIDR allocation
- subnet layout
- peering model
- forced-tunnel or route table assumptions
- firewall or Bastion placement
- production connectivity assumptions
- any backend migration or state movement

## Platform change requirements

| 항목                 | 내용                                                                                                                                                                           |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Affected path        | `platform/connectivity/kr/koreacentral/hub/00-hub-network`                                                                                                                     |
| Affected Azure scope | Future Korea Central hub virtual network resource group, VNet, subnets, route integration points, and peering integration points                                               |
| Blast radius         | Shared hub networking affects downstream private DNS, egress routing, operations access, and all spokes that depend on hub connectivity                                        |
| Validation command   | Not applicable yet; no OpenTofu files exist in this scaffold. Once `.tf` files are added, use `make validate STACK=platform/connectivity/kr/koreacentral/hub/00-hub-network`   |
| Rollback note        | Before implementation, rollback is documentation revert only. After resources are added, rollback must be plan-reviewed because hub networking can affect all dependent spokes |
| Remaining risk       | CIDR, subnet, route, firewall, Bastion, and peering decisions are not implemented yet and must be reviewed as architecture decisions before coding                             |

## Implementation notes

When this scaffold becomes an OpenTofu stack:

- keep one state owner for the hub network
- keep backend configuration externalized through `backend.hcl`
- expose stable outputs for downstream stacks
- document CIDR reservations in `docs/architecture.md` or an ADR if they change
- run `make fmt`
- run `make validate STACK=platform/connectivity/kr/koreacentral/hub/00-hub-network`

Do not combine hub network implementation with private DNS, egress security, or
access operations in the same task unless explicitly approved.
