# 02-identity-federation

## 파일별 역할

| 파일 | 하는 일 |
| --- | --- |
| `versions.tf` | Terraform CLI·`azurerm`·`azuread` provider 버전 고정 (`required_version`, `required_providers`). |
| `backend.tf` | 백엔드 **타입만** 선언 (`azurerm` + 빈 블록). `resource_group_name`·스토리지 계정 등은 **백엔드 블록에 변수를 쓸 수 없어서** `backend.hcl`에 두고 `terraform init -backend-config=backend.hcl`로 주입(부트스트랩 스크립트 출력·`backend.hcl.example`과 맞춤). |
| `providers.tf` | `azurerm`·`azuread` provider 설정(구독·테넌트는 변수로 연결). |
| `variables.tf` | 입력 변수(구독/테넌트, GitHub org·repo·브랜치, state 스토리지 이름, 구독 역할 등). |
| `main.tf` | 리소스 본체: Entra 앱 등록·SP·브랜치별 federated credential, 구독 RBAC, (선택) state 스토리지에 Storage Blob Data Contributor. |
| `outputs.tf` | GitHub Secrets에 넣을 client/tenant/subscription ID·OIDC subject 예시. |
| `terraform.tfvars.example` | 복사해 `terraform.tfvars`로 쓸 값 예시(gitignore됨). |
| `backend.hcl.example` | 복사해 `backend.hcl`로 쓸 백엔드 설정 예시(gitignore됨). `key`는 스택별로 유일해야 함. |
| `.terraform.lock.hcl` | Provider 체크섬 잠금. 팀·CI 재현성을 위해 커밋하는 것이 일반적. |

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
