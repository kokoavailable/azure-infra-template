# Bootstrap (Stage 1)

Creates the **remote state storage** used by every Terraform stack and documents what must exist before `platform/identity` / `platform/management` apply.

## Prerequisites

- Azure CLI (`az`) logged in with permission to create resource groups and storage accounts.
- A globally unique storage account name (3–24 lowercase letters/numbers).

## Order

1. Run **`bootstrap-state-storage.sh`** once per subscription (or per environment if you isolate state).
2. Copy **`backend.hcl.example`** from each stack to **`backend.hcl`** (gitignored), fill values from script output.
3. Apply **`platform/identity/02-identity-federation`** (GitHub OIDC app + RBAC including state blob access).
4. Apply **`platform/management/03-policy-governance`** (baseline policies + naming/tag conventions).
5. Configure GitHub repository secrets:
   - `AZURE_CLIENT_ID` — Terraform output `azure_application_client_id`
   - `AZURE_TENANT_ID` — your tenant ID
   - `AZURE_SUBSCRIPTION_ID` — subscription ID

Then run **`workflow_dispatch`** on `.github/workflows/platform-bootstrap-ci.yml` to verify OIDC (`azure/login` + `az account show`).

## Repository naming conventions

Documented as variables + optional audit policy in `platform/management/03-policy-governance`:

- Resource groups: `rg-<org>-<env>-<region>-<workload>` (adjust prefix via `resource_group_name_prefix`).
- Tags: at minimum `environment`, `owner`, `managed_by`, `cost_center` (aligned with `docs/naming-conventions.md`).

## Stacks without remote state

For the **first** apply of identity, if backend storage did not exist yet, use local state once, migrate, or apply identity with `-backend=false` locally then configure backend — prefer creating bootstrap storage first.
