# 00-hub-network

Hub virtual network, peering integration points, and hub subnets for Korea
Central.

This stack owns the first OpenTofu scaffold for the regional hub network. CIDR
and subnet layout remain human-approved inputs; this stack provides the state
boundary, naming pattern, resource group, virtual network, subnet resources, and
stable outputs for downstream stacks.

## Intended scope

This stack should own:

- Korea Central hub virtual network
- hub subnets for environment connectivity services
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
- environment-specific shared services

## Dependency direction

Allowed direction:

```text
stacks/dev/kr/koreacentral/hub/00-hub-network
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
- environment connectivity assumptions
- any backend migration or state movement

## Environment stack change requirements

| 항목                 | 내용                                                                                                                                                       |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Affected path        | `stacks/dev/kr/koreacentral/hub/00-hub-network`                                                                                                            |
| Affected Azure scope | Future Korea Central hub virtual network resource group, VNet, subnets, route integration points, and peering integration points                           |
| Blast radius         | Environment hub networking affects downstream private DNS, egress routing, operations access, and all spokes that depend on hub connectivity               |
| Validation command   | `make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network`                                                                                        |
| Rollback note        | Before apply, rollback is a code revert. After apply, rollback must be plan-reviewed because hub networking can affect all dependent spokes                |
| Remaining risk       | CIDR, subnet, route, firewall, Bastion, and peering decisions are inputs or future stacks and must be reviewed as architecture decisions before plan/apply |

## Implementation notes

When this scaffold becomes an OpenTofu stack:

- keep one state owner for the hub network
- keep backend configuration externalized through `backend.hcl`
- expose stable outputs for downstream stacks
- document CIDR reservations in `docs/architecture.md` or an ADR if they change
- run `make fmt`
- run `make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network`

## Commands

```bash
make fmt
make validate STACK=stacks/dev/kr/koreacentral/hub/00-hub-network
```

Planning requires approved `hub_address_space` and `hub_subnets` values plus
expected Azure/backend access:

```bash
make plan STACK=stacks/dev/kr/koreacentral/hub/00-hub-network
```

Do not combine hub network implementation with private DNS, egress security, or
access operations in the same task unless explicitly approved.
