# 05-private-dns

Private DNS zone lifecycle and hub-aligned resolution policy for Korea Central.
Spoke VNet links consume this design.

This stack is currently a scaffold. It documents the intended ownership boundary
for shared private DNS before OpenTofu resources are added.

## Intended scope

This stack should own:

- hub-owned Azure Private DNS zones for approved PaaS private endpoint
  namespaces
- hub-aligned VNet link policy
- shared resolver or forwarding assumptions when explicitly designed
- outputs consumed by spoke stacks that need approved private DNS zone IDs
- documentation of which private endpoint namespaces are centralized

This stack should not own:

- public DNS zones
- hub virtual network CIDR or subnet creation
- workload private endpoints
- workload-specific records that belong beside a spoke-owned private endpoint
- application ingress records
- production-only exceptions without explicit approval

## Dependency direction

Allowed direction:

```text
platform/connectivity/kr/koreacentral/hub/00-hub-network
-> platform/connectivity/kr/koreacentral/hub/05-private-dns
-> spoke private endpoint and configuration stacks
```

Do not introduce dependencies from this stack back into spokes. Spokes may
consume approved zone IDs or link policy outputs from this stack.

## Human decision gates

The following require explicit human approval before implementation or apply:

- list of centralized private DNS zones
- VNet link registration policy
- cross-spoke sharing model
- hybrid resolver or conditional forwarding design
- any DNS behavior that affects production resolution
- migration from duplicate spoke-owned zones to centralized hub zones
- backend migration or state movement

## Platform change requirements

| 항목                 | 내용                                                                                                                                                                                          |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Affected path        | `platform/connectivity/kr/koreacentral/hub/05-private-dns`                                                                                                                                    |
| Affected Azure scope | Future hub-owned private DNS zones, VNet links, resolver or forwarding integration points, and outputs consumed by spoke private endpoint stacks                                              |
| Blast radius         | Private DNS affects PaaS private endpoint resolution across linked VNets. Wrong zones, links, or resolver assumptions can break data, secret, configuration, edge, or observability workloads |
| Validation command   | Not applicable yet; no OpenTofu files exist in this scaffold. Once `.tf` files are added, use `make validate STACK=platform/connectivity/kr/koreacentral/hub/05-private-dns`                  |
| Rollback note        | Before implementation, rollback is documentation revert only. After resources are added, rollback must be plan-reviewed because private DNS changes can affect every linked spoke             |
| Remaining risk       | The exact zone list, link model, resolver behavior, and migration path from any duplicate zones are not implemented yet and require architecture review before coding                         |

## Implementation notes

When this scaffold becomes an OpenTofu stack:

- keep one state owner for shared private DNS
- keep backend configuration externalized through `backend.hcl`
- expose stable private DNS zone IDs for downstream stacks
- document centralized zones in `docs/dns-strategy.md`
- update or add an ADR if DNS ownership rules change
- run `make fmt`
- run `make validate STACK=platform/connectivity/kr/koreacentral/hub/05-private-dns`

Do not combine private DNS implementation with hub network, egress security, or
workload private endpoint implementation in the same task unless explicitly
approved.
