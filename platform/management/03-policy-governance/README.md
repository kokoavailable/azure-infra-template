# 03-policy-governance

Subscription-level **baseline Azure Policy** assignments:

- **Require a tag on resource groups** — default tag key `environment` (configurable).
- **Allowed locations** — defaults to `koreacentral` only (adjust `allowed_azure_regions`).

Resource group **naming** (`rg-<org>-<env>-<region>-<workload>`) is documented via `resource_group_name_pattern` and `docs/naming-conventions.md`. This minimal stack does not ship a custom RG-name audit policy (provider/API differences); add a management-group initiative later if you need automated enforcement.

## Prerequisites

Remote state backend configured like other stacks (`backend.hcl` with unique `key`, e.g. `platform/management/03-policy-governance.tfstate`).

## Apply

```bash
cd platform/management/03-policy-governance
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Toggle assignments with `assign_require_environment_tag_on_rg` or set `allowed_azure_regions = []` to disable region restriction.
