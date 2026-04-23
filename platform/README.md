# Platform stacks

Stage 1 (**minimal bootstrap**) lives here:

| Path | Purpose |
| --- | --- |
| `identity/02-identity-federation` | GitHub Actions OIDC app + federated credentials + RBAC (+ optional remote state blob access). |
| `management/03-policy-governance` | Baseline policies (tags, allowed regions). |
| `connectivity/` | Stage 2+ hub/network/DNS (placeholders today). |
| `shared-services/` | Shared prod/nonprod services (placeholders today). |

Before applying Terraform here, create remote state storage with **`scripts/bootstrap/bootstrap-state-storage.sh`** and configure each stack’s **`backend.hcl`**.

See also **`stacks/_stack-template`** for copying new stacks.
