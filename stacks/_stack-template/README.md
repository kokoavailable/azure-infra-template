# Stack template

Copy this directory when adding a new Terraform stack (platform or spoke).

## Steps

1. Duplicate `_stack-template` to the target path (for example `spokes/dev/app-main/kr/koreacentral/00-spoke-network`).
2. Rename `backend.hcl.example` → `backend.hcl` (gitignored), set `key` to a unique blob name.
3. Copy `terraform.tfvars.example` → `terraform.tfvars`, fill subscription and tagging values.
4. Replace the placeholder resource in `main.tf` with real modules/resources.
5. Run `terraform fmt`, `terraform init -backend-config=backend.hcl`, `terraform validate`.

Shared bootstrap context (OIDC + policies) lives under `platform/identity` and `platform/management`.
