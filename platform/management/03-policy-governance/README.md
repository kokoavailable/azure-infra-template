# 03-policy-governance

구독(Subscription) 범위에 **Azure 기본 정책(Built-in policy)** 만 할당하는 최소 거버넌스 스택이다. 커스텀 정의나 관리 그룹 이니셔티브는 포함하지 않는다.

## 파일별 역할

| 파일 | 하는 일 |
| --- | --- |
| `versions.tf` | Terraform CLI·`azurerm` provider 버전 고정. |
| `backend.tf` | 백엔드 타입만 선언(`azurerm`). 실제 값은 `backend.hcl`로 `terraform init -backend-config=backend.hcl` 주입. |
| `providers.tf` | `azurerm` provider(`subscription_id`, `tenant_id`). |
| `variables.tf` | 대상 구독·테넌트, 정책 할당 이름 접두사(`project_prefix`), RG 이름 규칙 문서용 문자열, 태그·리전 제한 스위치. |
| `locals.tf` | 정책 할당 리소스 이름(`<prefix>-req-env-rg`, `<prefix>-allowed-locs`). |
| `main.tf` | Built-in 정의 조회(`Require a tag on resource groups`, `Allowed locations`) 및 `azurerm_subscription_policy_assignment`. |
| `outputs.tf` | 각 할당 리소스 ID와 문서화된 RG 이름 패턴. |
| `terraform.tfvars.example` | 복사해 `terraform.tfvars`로 사용(gitignore). |

## 무엇을 하는가

- **리소스 그룹에 태그 필수** — 기본 태그 키는 `environment`(`mandatory_environment_tag_name`으로 변경 가능). `assign_require_environment_tag_on_rg = false` 로 끈다.
- **허용 리전** — 기본은 `koreacentral`만(`allowed_azure_regions`). 빈 리스트 `[]` 이면 이 할당을 만들지 않는다.

리소스 그룹 **이름 규칙**(`rg-<org>-<env>-<region>-<workload>`)은 출력·변수(`resource_group_name_pattern`)와 저장소 루트의 [`docs/naming-conventions.md`](../../../docs/naming-conventions.md)로 문서화만 한다. 이 스택은 구독 단위 커스텀 정의 없이 RG 이름을 자동 감사하지 않는다(프로바이더/API 차이). 관리 그룹 이니셔티브로 강제가 필요하면 나중에 추가한다.

## 사전 조건

1. 다른 스택과 같이 원격 state 백엔드가 준비되어 있어야 한다(`scripts/bootstrap/bootstrap-state-storage.sh` 등).
2. `backend.hcl`에 이 스택 전용 **`key`** 를 둔다(예: `platform/management/03-policy-governance.tfstate`). 팀 템플릿은 `stacks/_stack-template/backend.hcl.example` 참고.
3. `terraform.tfvars.example` → **`terraform.tfvars`** 복사 후 `subscription_id`, `tenant_id` 등 입력.

**권한:** 대상 구독에서 정책 할당을 만들 수 있어야 한다. 예: 구독 범위 **Owner**, **Contributor**, 또는 **리소스 정책 기여자(Resource Policy Contributor)** 등 `Microsoft.Authorization/policyAssignments/write` 가 포함된 역할.

## Apply

```bash
cd platform/management/03-policy-governance
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## 주요 변수

| 변수 | 설명 |
| --- | --- |
| `assign_require_environment_tag_on_rg` | RG 태그 필수 정책 할당 여부(기본 `true`). |
| `mandatory_environment_tag_name` | 필수 태그 키(기본 `environment`). |
| `allowed_azure_regions` | 허용 리전 목록; `[]` 이면 리전 제한 할당 없음. |
| `project_prefix` | 할당 이름 접두사(기본 `plt`). |
| `resource_group_name_pattern` | 정책이 아니라 문서·출력용 RG 명명 규칙 문자열. |

## Outputs

| Output | 용도 |
| --- | --- |
| `policy_assignment_require_tag_on_rg_id` | RG 태그 정책 할당 리소스 ID(비활성 시 `null`). |
| `policy_assignment_allowed_locations_id` | 허용 리전 할당 리소스 ID(비활성 시 `null`). |
| `documented_resource_group_name_pattern` | 모듈·문서와 맞춘 RG 이름 패턴 문자열. |

## 의존성·순서

원격 state가 있으면 적용 가능하다. [`scripts/bootstrap/README.md`](../../../scripts/bootstrap/README.md) 흐름에서는 identity 부트스트랩 이후 baseline 정책 단계로 두는 것이 자연스럽다. 다른 플랫폼 스택과 **state `key` 충돌** 만 피하면 된다.
