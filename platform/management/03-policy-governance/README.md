# 03-policy-governance

구독(Subscription) 범위에 **Azure 기본 정책(Built-in policy)** 만 할당하는 최소 거버넌스 스택이다. 커스텀 정의나 관리 그룹 이니셔티브는 포함하지 않는다.

## 파일별 역할

| 파일                       | 하는 일                                                                                                                  |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `versions.tf`              | OpenTofu/Terraform CLI·`azurerm` provider 버전 고정.                                                                     |
| `backend.tf`               | 백엔드 타입만 선언(`azurerm`). 실제 값은 `backend.hcl`로 Makefile `plan`/`apply` 경로에서 주입.                          |
| `providers.tf`             | `azurerm` provider(`subscription_id`, `tenant_id`).                                                                      |
| `variables.tf`             | 대상 구독·테넌트, 정책 할당 이름 접두사(`project_prefix`), RG 이름 규칙 문서용 문자열, 태그·리전 제한 스위치.            |
| `locals.tf`                | 정책 할당 리소스 이름(태그별 `<prefix>-rq-…`, `<prefix>-allowed-locs`).                                                  |
| `main.tf`                  | Built-in 정의 조회(`Require a tag on resource groups`, `Allowed locations`) 및 `azurerm_subscription_policy_assignment`. |
| `outputs.tf`               | 각 할당 리소스 ID와 문서화된 RG 이름 패턴.                                                                               |
| `terraform.tfvars.example` | 복사해 `terraform.tfvars`로 사용(gitignore).                                                                             |

## 무엇을 하는가

- **리소스 그룹에 태그 필수** — Built-in `Require a tag on resource groups` 를 **태그 키마다 한 번씩** 할당한다(기본 키 목록은 `["environment"]`). `assign_require_environment_tag_on_rg = false` 로 전부 끈다.
- **허용 리전** — 기본은 `koreacentral`만(`allowed_azure_regions`). 빈 리스트 `[]` 이면 이 할당을 만들지 않는다.

리소스 그룹 **이름 규칙**(`rg-<org>-<env>-<region>-<workload>`)은 출력·변수(`resource_group_name_pattern`)와 저장소 루트의 [`docs/naming-conventions.md`](../../../docs/naming-conventions.md)로 문서화만 한다. 이 스택은 구독 단위 커스텀 정의 없이 RG 이름을 자동 감사하지 않는다(프로바이더/API 차이). 관리 그룹 이니셔티브로 강제가 필요하면 나중에 추가한다.

## 사전 조건

1. 다른 스택과 같이 원격 state 백엔드가 준비되어 있어야 한다(`scripts/bootstrap/bootstrap-state-storage.sh` 등).
2. `backend.hcl`에 이 스택 전용 **`key`** 를 둔다(예: `platform/management/03-policy-governance.tfstate`). 팀 템플릿은 `stacks/_stack-template/backend.hcl.example` 참고.
3. `terraform.tfvars.example` → **`terraform.tfvars`** 복사 후 `subscription_id`, `tenant_id` 등 입력.

**권한:** 대상 구독에서 정책 할당을 만들 수 있어야 한다. 예: 구독 범위 **Owner**, **Contributor**, 또는 **리소스 정책 기여자(Resource Policy Contributor)** 등 `Microsoft.Authorization/policyAssignments/write` 가 포함된 역할.

## 운영 명령

저장소 루트의 Makefile을 사용한다. 이 스택에서 직접 raw `terraform` 또는
`tofu` 명령을 실행하는 것은 지원 경로가 아니다.

검증:

```bash
make validate STACK=platform/management/03-policy-governance
```

계획 확인:

```bash
make plan STACK=platform/management/03-policy-governance
```

적용:

```bash
make apply STACK=platform/management/03-policy-governance
```

`plan`/`apply`는 다음 입력이 준비되어 있어야 한다.

- `platform/terraform.shared.tfvars`
- `platform/management/03-policy-governance/terraform.tfvars` 또는
  `*.auto.tfvars`
- `platform/management/03-policy-governance/backend.hcl`

`make plan`은 사용자가 plan을 기대하고 Azure 인증 및 원격 backend 접근이
준비된 경우에만 실행한다. `make apply`는 명시적 승인 없이는 실행하지
않는다.

## Platform change requirements

| 항목                 | 내용                                                                                                                                                                                                               |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Affected path        | `platform/management/03-policy-governance`                                                                                                                                                                         |
| Affected Azure scope | 대상 Azure subscription 범위의 Policy Assignment                                                                                                                                                                   |
| Blast radius         | 구독 전체 리소스 그룹 태그 요구사항과 허용 리전 정책에 영향. 새 리소스 그룹 또는 리전 제한 대상 리소스 생성 흐름이 막힐 수 있다.                                                                                   |
| Validation command   | `make validate STACK=platform/management/03-policy-governance`                                                                                                                                                     |
| Rollback note        | 정책 할당 변경을 되돌리는 PR을 만든 뒤 plan을 검토하고 승인된 apply 경로로 반영한다. 긴급 완화가 필요하면 해당 assignment를 비활성화하는 변수 변경을 우선 검토한다. state 명령이나 수동 삭제는 기본 경로가 아니다. |
| Remaining risk       | Built-in 정책 동작과 기존 리소스 예외는 Azure Policy 평가 시점과 리소스 종류에 따라 다를 수 있다. 적용 전 plan과 정책 예외 필요 여부를 확인해야 한다.                                                              |

## 주요 변수

| 변수                                   | 설명                                                         |
| -------------------------------------- | ------------------------------------------------------------ |
| `assign_require_environment_tag_on_rg` | RG 태그 필수 정책 할당 여부(기본 `true`).                    |
| `mandatory_resource_group_tag_keys`    | 필수 태그 키 목록; 키마다 별도 할당(기본 `["environment"]`). |
| `allowed_azure_regions`                | 허용 리전 목록; `[]` 이면 리전 제한 할당 없음.               |
| `project_prefix`                       | 할당 이름 접두사(기본 `plt`).                                |
| `resource_group_name_pattern`          | 정책이 아니라 문서·출력용 RG 명명 규칙 문자열.               |

## Outputs

| Output                                    | 용도                                                      |
| ----------------------------------------- | --------------------------------------------------------- |
| `policy_assignment_require_tag_on_rg_ids` | 태그 키 → RG 태그 정책 할당 리소스 ID 맵(비활성 시 `{}`). |
| `policy_assignment_allowed_locations_id`  | 허용 리전 할당 리소스 ID(비활성 시 `null`).               |
| `documented_resource_group_name_pattern`  | 모듈·문서와 맞춘 RG 이름 패턴 문자열.                     |

## 의존성·순서

원격 state가 있으면 적용 가능하다. [`scripts/bootstrap/README.md`](../../../scripts/bootstrap/README.md) 흐름에서는 identity 부트스트랩 이후 baseline 정책 단계로 두는 것이 자연스럽다. 다른 플랫폼 스택과 **state `key` 충돌** 만 피하면 된다.
