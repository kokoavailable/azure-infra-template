# 10-egress-routing-security

Egress path, routing intent, and hub-level security controls for Korea Central.

This stack owns the first OpenTofu scaffold for centralized egress route intent.
Route table and route choices remain human-approved inputs; this stack provides
the state boundary, optional hub-owned route tables, and stable outputs for
downstream route consumers.

## Intended scope

This stack should own:

- Azure Firewall or approved hub egress inspection resources when explicitly
  designed
- route tables and route intent that direct approved spoke traffic through hub
  inspection paths
- shared NAT or outbound policy integration when it is environment-hub-owned
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
stacks/dev/kr/koreacentral/hub/00-hub-network
-> stacks/dev/kr/koreacentral/hub/10-egress-routing-security
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

## Environment stack change requirements

| 항목                 | 내용                                                                                                                                                                                                             |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Affected path        | `stacks/dev/kr/koreacentral/hub/10-egress-routing-security`                                                                                                                                                      |
| Affected Azure scope | Future hub egress resources such as Azure Firewall, firewall policy, route tables, NAT/outbound controls, diagnostic settings, and outputs consumed by spoke routing stacks                                      |
| Blast radius         | Egress routing affects outbound connectivity for every spoke that adopts hub route intent. Wrong routes or firewall policy can break package retrieval, service access, private endpoints, or production traffic |
| Validation command   | `make validate STACK=stacks/dev/kr/koreacentral/hub/10-egress-routing-security`                                                                                                                                  |
| Rollback note        | Before apply, rollback is a code revert. After apply, rollback must be plan-reviewed because route changes can immediately affect spoke connectivity                                                             |
| Remaining risk       | Firewall policy, default routes, NAT ownership, diagnostics, and production egress behavior remain input or future-stack decisions and require architecture/security review before plan/apply                    |

## Implementation notes

- keep one state owner for hub egress and route intent
- keep backend configuration externalized through `backend.hcl`
- expose stable outputs for route consumers
- document egress assumptions in `docs/security-baseline.md` or an ADR if they
  change
- include diagnostics and logging expectations with the first implementation
- run `make fmt`
- run `make validate STACK=stacks/dev/kr/koreacentral/hub/10-egress-routing-security`

## Commands

```bash
make fmt
make validate STACK=stacks/dev/kr/koreacentral/hub/10-egress-routing-security
```

Planning requires approved `route_tables` values plus expected Azure/backend
access:

```bash
make plan STACK=stacks/dev/kr/koreacentral/hub/10-egress-routing-security
```

Do not combine egress security implementation with hub network, private DNS, or
access operations in the same task unless explicitly approved.
