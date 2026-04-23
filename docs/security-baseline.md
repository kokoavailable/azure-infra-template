# Security Baseline

## Purpose
This document defines the minimum security controls expected across platform and workload stacks.

## Connectivity placement (Stage 0)
| Concern | Placement | Notes |
| --- | --- | --- |
| Ingress (App Gateway / WAF for an application) | **Spoke** | Per workload or spoke boundary; keeps blast radius scoped to the app. |
| Egress filtering, forced tunneling intent | **Hub** | Azure Firewall / route intent centralized; spokes send north–south traffic via hub design. |
| Shared NAT | **Hub** (or hub policy) | Avoid ad hoc per-spoke egress unless documented. |
| Bastion / shared ops access | **Hub** (or hub-owned ops stack) | Prefer consistent jump paths over scattered public IPs on spokes. |
| Private endpoints | **Spoke** (resource side) | DNS registration follows hub-aligned private DNS strategy (`dns-strategy.md`). |

## Security Principles
- Prefer short-lived identity over long-lived secrets.
- Grant least privilege at the smallest practical scope.
- Default to private connectivity for sensitive services.
- Make logging, governance, and policy enforcement part of the platform baseline.

## Identity and Access
- Use workload identity federation where possible instead of long-lived secrets.
- Grant RBAC roles scoped to the smallest practical boundary.
- Review privileged assignments and break-glass access regularly.
- Separate operator roles from application runtime roles.

## Network Controls
- Prefer private endpoints and private routing for stateful services.
- Restrict inbound access to approved edge services (spoke App Gateway/WAF) and hub-approved management paths.
- Segment subnets by workload role and apply NSG rules explicitly.
- Avoid broad allow rules that mix platform administration and workload traffic.

## Secrets and Certificates
- Store secrets and certificates in Key Vault.
- Rotate secrets on a documented schedule or in response to incidents.
- Do not commit live credentials, private keys, or environment-specific secret values.
- Keep access to secret material auditable and role-scoped.

## Compute Hardening
- Build from controlled base images.
- Apply patching through image refresh or documented update procedures.
- Disable unnecessary services and expose only required ports.
- Keep bootstrapping minimal so instances remain reproducible.

## Logging and Governance
- Enable diagnostic settings and retain audit-relevant logs.
- Enforce baseline policies for region usage, tagging, encryption, and network posture.
- Treat policy exemptions as time-bound and reviewed exceptions.
- Ensure security-relevant alerts map to an owner and response path.

## Minimum Expectations for New Stacks
Every new stack should demonstrate:
- Approved identity model
- Explicit network boundaries
- Secret handling through approved services
- Baseline diagnostics and audit visibility
- Policy compliance or documented exceptions
