# 10-egress-routing-security

Egress path, routing intent, and hub-level security controls for Korea Central.

This stack is currently a scaffold. It documents the intended ownership boundary
for centralized egress before OpenTofu resources are added.

## Intended scope

This stack should own:

- Azure Firewall or approved hub egress inspection resources when explicitly
  designed
- route tables and route intent that direct approved spoke traffic through hub
  inspection paths
- shared NAT or outbound policy integration when it is hub-owned
- diagnostic and logging expectations for egress controls
- outputs consumed by downstream hub or spoke routing stacks

This stack should not own:

- hub VNet or subnet creation
- private DNS zone lifecycle
- workload spoke subnets
- workload-specific NSG rules
- application ingress WAF or edge routing
- emergency production exceptions without explicit approval

## Dependency direction

Allowed direction:

```text
platform/connectivity/kr/koreacentral/hub/00-hub-network
-> platform/connectivity/kr/koreacentral/hub/10-egress-routing-security
-> spoke route association or routing policy consumers
```

Do not introduce dependencies from this stack back into spokes. Spokes may
consume route table IDs, firewall private IPs, or documented route intent outputs
from this stack when those outputs exist.

## Human decision gates

The following require explicit human approval before implementation or apply:

- forced-tunnel design
- default route propagation to spokes
- Azure Firewall SKU, policy, and rule collection model
- NAT and outbound IP ownership
- route table association model
- production egress inspection behavior
- broad allow rules or internet egress exceptions
- backend migration or state movement

## Platform change requirements

| 항목                 | 내용                                                                                                                                                                                                             |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Affected path        | `platform/connectivity/kr/koreacentral/hub/10-egress-routing-security`                                                                                                                                           |
| Affected Azure scope | Future hub egress resources such as Azure Firewall, firewall policy, route tables, NAT/outbound controls, diagnostic settings, and outputs consumed by spoke routing stacks                                      |
| Blast radius         | Egress routing affects outbound connectivity for every spoke that adopts hub route intent. Wrong routes or firewall policy can break package retrieval, service access, private endpoints, or production traffic |
| Validation command   | Not applicable yet; no OpenTofu files exist in this scaffold. Once `.tf` files are added, use `make validate STACK=platform/connectivity/kr/koreacentral/hub/10-egress-routing-security`                         |
| Rollback note        | Before implementation, rollback is documentation revert only. After resources are added, rollback must be plan-reviewed because route and firewall changes can immediately affect spoke connectivity             |
| Remaining risk       | Firewall policy, default routes, NAT ownership, diagnostics, and production egress behavior are not implemented yet and require architecture/security review before coding                                       |

## Implementation notes

When this scaffold becomes an OpenTofu stack:

- keep one state owner for hub egress and route intent
- keep backend configuration externalized through `backend.hcl`
- expose stable outputs for route consumers
- document egress assumptions in `docs/security-baseline.md` or an ADR if they
  change
- include diagnostics and logging expectations with the first implementation
- run `make fmt`
- run `make validate STACK=platform/connectivity/kr/koreacentral/hub/10-egress-routing-security`

Do not combine egress security implementation with hub network, private DNS, or
access operations in the same task unless explicitly approved.
