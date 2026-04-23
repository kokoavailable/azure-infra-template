# 02-identity-federation

Creates the **GitHub Actions OIDC** application registration, federated credentials for branch refs, the related **service principal**, and RBAC:

- Subscription-level role for infrastructure deployment (default **Contributor**).
- **Storage Blob Data Contributor** on the remote state storage account when `terraform_state_*` variables are set — required when using `use_azuread_auth = true` on the `azurerm` backend.

## Prerequisites

1. Run `scripts/bootstrap/bootstrap-state-storage.sh` and note the suggested `backend.hcl` snippet.
2. Copy `backend.hcl.example` → **`backend.hcl`** (gitignored), set `key` to `platform/identity/02-identity-federation.tfstate`.
3. Copy `terraform.tfvars.example` → **`terraform.tfvars`**, fill subscription, tenant, GitHub org/repo, and optionally state storage names.

## Apply

```bash
cd platform/identity/02-identity-federation
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Outputs → GitHub secrets

| Output | GitHub secret |
| --- | --- |
| `azure_application_client_id` | `AZURE_CLIENT_ID` |
| `azure_tenant_id` (or use known tenant) | `AZURE_TENANT_ID` |
| `azure_subscription_id` | `AZURE_SUBSCRIPTION_ID` |

Then run **Actions → Platform bootstrap CI → workflow_dispatch → oidc-azure-smoke** (after `fmt-validate` is green) to confirm `azure/login` works.

## Dependencies

Apply after remote state exists. Management/policy stack may run before or after; avoid circular dependency on same state bucket keys.
