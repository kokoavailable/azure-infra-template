# 05-private-dns

Private DNS zone lifecycle and environment-hub-aligned resolution policy for Korea Central.
Spoke VNet links consume this design.

This stack owns the first OpenTofu scaffold for environment-hub private DNS.
Zone and VNet link choices remain human-approved inputs; this stack provides
the state boundary, approved private DNS zone resources, optional VNet links,
and stable outputs for downstream private endpoint consumers.

## Intended scope

This stack should own:

- environment-hub-owned Azure Private DNS zones for approved PaaS private endpoint
  namespaces
- environment-hub-aligned VNet link policy
- environment resolver or forwarding assumptions when explicitly designed
- outputs consumed by spoke stacks that need approved private DNS zone IDs
- documentation of which private endpoint namespaces are centralized

This stack should not own:

- public DNS zones
- hub virtual network CIDR or subnet creation
- workload private endpoints
- workload-specific records that belong beside a spoke-owned private endpoint
- application ingress records
- environment-specific exceptions without explicit approval

## Dependency direction

Allowed direction:

```text
stacks/dev/kr/koreacentral/hub/00-hub-network
-> stacks/dev/kr/koreacentral/hub/05-private-dns
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

## Environment stack change requirements

| 항목                 | 내용                                                                                                                                                                                          |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Affected path        | `stacks/dev/kr/koreacentral/hub/05-private-dns`                                                                                                                                               |
| Affected Azure scope | Future environment-hub-owned private DNS zones, VNet links, resolver or forwarding integration points, and outputs consumed by spoke private endpoint stacks                                  |
| Blast radius         | Private DNS affects PaaS private endpoint resolution across linked VNets. Wrong zones, links, or resolver assumptions can break data, secret, configuration, edge, or observability workloads |
| Validation command   | `make validate STACK=stacks/dev/kr/koreacentral/hub/05-private-dns`                                                                                                                           |
| Rollback note        | Before apply, rollback is a code revert. After apply, rollback must be plan-reviewed because private DNS changes can affect every linked spoke in this environment                            |
| Remaining risk       | The exact zone list, link model, resolver behavior, and migration path from any duplicate zones are input decisions and require architecture review before plan/apply                         |

## Implementation notes

- keep one state owner for environment private DNS
- keep backend configuration externalized through `backend.hcl`
- expose stable private DNS zone IDs for downstream stacks
- document centralized zones in `docs/dns-strategy.md`
- update or add an ADR if DNS ownership rules change
- run `make fmt`
- run `make validate STACK=stacks/dev/kr/koreacentral/hub/05-private-dns`

## Commands

```bash
make fmt
make validate STACK=stacks/dev/kr/koreacentral/hub/05-private-dns
```

Planning requires approved `private_dns_zones` and `virtual_network_links`
values plus expected Azure/backend access:

```bash
make plan STACK=stacks/dev/kr/koreacentral/hub/05-private-dns
```

Do not combine private DNS implementation with hub network, egress security, or
workload private endpoint implementation in the same task unless explicitly
approved.
