# 02-identity-federation

## 파일별 역할

| 파일                       | 하는 일                                                                                                                                                                                                                                         |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `versions.tf`              | OpenTofu/Terraform CLI·`azurerm`·`azuread` provider 버전 고정 (`required_version`, `required_providers`).                                                                                                                                       |
| `backend.tf`               | 백엔드 **타입만** 선언 (`azurerm` + 빈 블록). `resource_group_name`·스토리지 계정 등은 **백엔드 블록에 변수를 쓸 수 없어서** `backend.hcl`에 두고 Makefile `plan`/`apply` 경로에서 주입(부트스트랩 스크립트 출력·`backend.hcl.example`과 맞춤). |
| `providers.tf`             | `azurerm`·`azuread` provider 설정(구독·테넌트는 변수로 연결).                                                                                                                                                                                   |
| `variables.tf`             | 입력 변수(구독/테넌트, GitHub org·repo·브랜치, state 스토리지 이름, 구독 역할 등).                                                                                                                                                              |
| `main.tf`                  | 리소스 본체: Entra 앱 등록·SP·브랜치별 federated credential, 구독 RBAC, (선택) state 스토리지에 Storage Blob Data Contributor.                                                                                                                  |
| `outputs.tf`               | GitHub Secrets에 넣을 client/tenant/subscription ID·OIDC subject 예시.                                                                                                                                                                          |
| `terraform.tfvars.example` | 복사해 `terraform.tfvars`로 쓸 값 예시(gitignore됨).                                                                                                                                                                                            |
| `backend.hcl.example`      | 복사해 `backend.hcl`로 쓸 백엔드 설정 예시(gitignore됨). `key`는 스택별로 유일해야 함.                                                                                                                                                          |
| `.terraform.lock.hcl`      | Provider 체크섬 잠금. 팀·CI 재현성을 위해 커밋하는 것이 일반적.                                                                                                                                                                                 |

Creates the **GitHub Actions OIDC** application registration, federated credentials for branch refs, the related **service principal**, and RBAC:

- Subscription-level role for infrastructure deployment (default **Contributor**).
- **Storage Blob Data Contributor** on the remote state storage account when `terraform_state_*` variables are set — required when using `use_azuread_auth = true` on the `azurerm` backend.

## Prerequisites

1. Run `scripts/bootstrap/bootstrap-state-storage.sh` and note the suggested `backend.hcl` snippet.
2. Copy `backend.hcl.example` → **`backend.hcl`** (gitignored), set `key` to `platform/identity/02-identity-federation.tfstate`.
3. Copy `terraform.tfvars.example` → **`terraform.tfvars`**, fill subscription, tenant, GitHub org/repo, and optionally state storage names.

## 운영 명령

저장소 루트의 Makefile을 사용한다. 이 스택에서 직접 raw `terraform` 또는
`tofu` 명령을 실행하는 것은 지원 경로가 아니다.

검증:

```bash
make validate STACK=platform/identity/02-identity-federation
```

계획 확인:

```bash
make plan STACK=platform/identity/02-identity-federation
```

적용:

```bash
make apply STACK=platform/identity/02-identity-federation
```

`plan`/`apply`는 다음 입력이 준비되어 있어야 한다.

- `platform/terraform.shared.tfvars`
- `platform/identity/02-identity-federation/terraform.tfvars` 또는
  `*.auto.tfvars`
- `platform/identity/02-identity-federation/backend.hcl`

`make plan`은 사용자가 plan을 기대하고 Azure 인증 및 원격 backend 접근이
준비된 경우에만 실행한다. `make apply`는 명시적 승인 없이는 실행하지
않는다.

## Platform change requirements

| 항목                 | 내용                                                                                                                                                                                                                                                                                                   |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Affected path        | `platform/identity/02-identity-federation`                                                                                                                                                                                                                                                             |
| Affected Azure scope | Microsoft Entra application/service principal, GitHub Actions federated credentials, 대상 Azure subscription RBAC, 선택적 tfstate storage account Blob RBAC                                                                                                                                            |
| Blast radius         | GitHub Actions가 Azure에 인증하고 subscription 범위에서 배포할 수 있는 권한에 영향. branch subject, audience, role scope가 잘못되면 CI 인증 실패 또는 과도한 배포 권한으로 이어질 수 있다.                                                                                                             |
| Validation command   | `make validate STACK=platform/identity/02-identity-federation`                                                                                                                                                                                                                                         |
| Rollback note        | OIDC/RBAC 변경을 되돌리는 PR을 만든 뒤 plan을 검토하고 승인된 apply 경로로 반영한다. 긴급 완화가 필요하면 federated credential branch 범위 축소 또는 `enable_subscription_role_assignment = false` 같은 변수 변경을 우선 검토한다. 수동 Entra/RBAC 삭제는 drift를 만들 수 있으므로 기본 경로가 아니다. |
| Remaining risk       | `subscription_role_name` 기본값은 `Contributor`라 넓은 권한이다. 실제 운영 전 최소 권한 역할과 scope를 재검토해야 하며, GitHub branch subject가 보호 브랜치 정책과 일치하는지 확인해야 한다.                                                                                                           |

## Outputs → GitHub secrets

| Output                                  | GitHub secret           |
| --------------------------------------- | ----------------------- |
| `azure_application_client_id`           | `AZURE_CLIENT_ID`       |
| `azure_tenant_id` (or use known tenant) | `AZURE_TENANT_ID`       |
| `azure_subscription_id`                 | `AZURE_SUBSCRIPTION_ID` |

Then run **Actions → Platform bootstrap CI → workflow_dispatch → oidc-azure-smoke** (after `fmt-validate` is green) to confirm `azure/login` works.

## Dependencies

Apply after remote state exists. Management/policy stack may run before or after; avoid circular dependency on same state bucket keys.
