# 20-access-ops

Shared operational access and environment-hub-owned access primitives.

This stack owns the first OpenTofu scaffold for dev hub operational access.
The custom Linux jumpbox remains disabled by default and is created only when
explicitly configured with an approved subnet, SSH public key, and source
address allowlist when public SSH is enabled.

## Intended scope

This stack should own:

- environment-hub-owned operational access primitives
- optional custom Linux jumpbox virtual machine
- jumpbox network interface, network security group, and optional public IP
- stable outputs consumed by operator access documentation or downstream stacks

This stack should not own:

- hub VNet or subnet creation
- workload compute
- workload private endpoints
- application ingress
- private keys or operator credentials
- broad operator RBAC grants or emergency access exceptions

## Dependency direction

Allowed direction:

```text
stacks/dev/kr/koreacentral/hub/00-hub-network
-> stacks/dev/kr/koreacentral/hub/20-access-ops
-> operator access consumers
```

Do not introduce dependencies from this stack back into spokes.

## Human decision gates

The following require explicit human approval before implementation or apply:

- jumpbox subnet placement
- public IP naming and exposure
- SSH source address allowlist
- SSH public key lifecycle
- base image selection and patching model
- operator access model
- RBAC scope for operational access
- production access assumptions
- backend migration or state movement

## Environment stack change requirements

| 항목                 | 내용                                                                                                                                                                          |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Affected path        | `stacks/dev/kr/koreacentral/hub/20-access-ops`                                                                                                                                |
| Affected Azure scope | Future hub operational access resources such as custom jumpbox VM, NIC, NSG, optional public IP, and outputs consumed by access documentation or downstream consumers        |
| Blast radius         | Operational access affects how maintainers reach private workloads. Wrong subnet, public IP, SSH allowlist, image, or RBAC assumptions can expose or block management paths  |
| Validation command   | `make validate STACK=stacks/dev/kr/koreacentral/hub/20-access-ops`                                                                                                            |
| Rollback note        | Before apply, rollback is a code revert. After apply, rollback must be plan-reviewed because access resources can affect operator reachability and public management exposure |
| Remaining risk       | Jumpbox placement, SSH exposure, key lifecycle, image patching, RBAC, and production access behavior remain input or future-stack decisions and require review before apply  |

## Implementation notes

- keep one state owner for hub access operations
- keep backend configuration externalized through `backend.hcl`
- keep the custom jumpbox disabled until subnet placement, SSH source ranges,
  image, and key lifecycle are approved
- disable password authentication on the jumpbox
- require an SSH source allowlist whenever a public IP is configured
- document access assumptions in `docs/security-baseline.md` or an ADR if they
  change
- run `make fmt`
- run `make validate STACK=stacks/dev/kr/koreacentral/hub/20-access-ops`

## Commands

```bash
make fmt
make validate STACK=stacks/dev/kr/koreacentral/hub/20-access-ops
```

Planning requires approved `jumpbox` values plus expected Azure/backend access:

```bash
make plan STACK=stacks/dev/kr/koreacentral/hub/20-access-ops
```

Do not combine access operations implementation with hub network, private DNS,
egress security, or workload compute implementation in the same task unless
explicitly approved.
