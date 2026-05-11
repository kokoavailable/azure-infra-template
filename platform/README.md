# Platform stacks

Stage 1 (**minimal bootstrap**) lives here:

| Path                              | Purpose                                                                                       |
| --------------------------------- | --------------------------------------------------------------------------------------------- |
| `identity/02-identity-federation` | GitHub Actions OIDC app + federated credentials + RBAC (+ optional remote state blob access). |
| `management/03-policy-governance` | Baseline policies (tags, allowed regions).                                                    |
| `connectivity/`                   | Global connectivity such as public DNS. Environment hubs live under `stacks/<env>/.../hub`.   |
| `shared-services/`                | Shared prod/nonprod services (placeholders today).                                            |

Before applying OpenTofu/Terraform here, create remote state storage with **`scripts/bootstrap/bootstrap-state-storage.sh`** and configure each stack’s **`backend.hcl`**.

**Variables (explicit, no symlink):**

| File                                   | Purpose                                                                                            |
| -------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **`platform/terraform.shared.tfvars`** | `subscription_id`, `tenant_id` once (copy from **`terraform.shared.tfvars.example`**; gitignored). |
| **`<stack>/terraform.tfvars`**         | Stack-only inputs (copy from each **`terraform.tfvars.example`**).                                 |

**Runs:** use repo-root **`Makefile`** so CI and local stay aligned — **`tofu`** with **`-var-file`** for both files (shared first, stack second; stack wins on duplicate keys).

```bash
make plan  STACK=platform/identity/02-identity-federation
make apply STACK=platform/identity/02-identity-federation
```

From inside a stack directory:

```bash
make -f "$(git rev-parse --show-toplevel)/Makefile" plan-here
```

Plain `cd`…`tofu apply` without those two **`-var-file`** flags is intentionally not the supported path.

See also **`templates/_stack-template`** for copying new stacks.
