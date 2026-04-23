# 변경 요약 (change1)

이 문서는 최근 작업에서 반영된 수정 사항을 한 곳에 모은 요약이다. (문서·디렉터리 정리, 플랫폼 부트스트랩 코드·CI 포함.)

---

## 1. Stage 0 — 설계 고정 및 레포 구조

### 1.1 문서 (`docs/`)

| 파일 | 변경 요지 |
| --- | --- |
| `architecture.md` | Stage 0 원칙 표(환경 dev/stg/prod, 리전 kr/koreacentral, 허브 1개/리전, 스포크 단위, DNS·PE·Ingress/Egress). 예시 CIDR 표. 레이아웃 경로·`readme2.md` 참조. |
| `layer-dependency.md` | 플랫폼 적용 순서(글로벌 → 허브 → shared-services → 스포크), 스포크 접두사 00–40과 레이어 매핑, Edge는 스포크 App GW/WAF. |
| `dns-strategy.md` | Stage 0 표(퍼블릭 글로벌, 프라이빗 허브 중심, PE는 스포크·DNS는 허브 정렬), ADR 링크. |
| `security-baseline.md` | Ingress/Egress/NAT/Bastion/PE 배치 표. |
| `stack-conventions.md` | `platform/…`, `spokes/<env>/<spoke>/kr/koreacentral/…` 경로 규약·접두사 표. |

### 1.2 디렉터리 스켈레톤

- **`platform/`**: `identity/02-identity-federation`, `management/03-policy-governance`, `connectivity/global/00-dns-public`, `connectivity/kr/koreacentral/hub/`(00·05·10·20), `shared-services/nonprod|prod` 등 `readme2.md`와 맞춘 폴더 + 스택별 `README.md`.
- **`spokes/`**: `dev|stg|prod` × `app-main` / `shared-observability` / `shared-airflow` — `readme2.md`와 동일하게(dev는 `app-main`만·`40-observability` 없음 등).

### 1.3 `readme2.md`

- 상단에 Stage 0 문서 링크, **현재 상태**(README 위주·`.tf`는 목표), `modules/` 등 예정 표기.
- `stg`의 `shared-observability` / `shared-airflow` 트리를 `prod`와 같이 풀 경로로 통일.
- `shared-services`에 `nonprod/README.md`, `prod/README.md` 줄 반영.

---

## 2. Stage 1 — 플랫폼 최소 부트스트랩

### 2.1 `scripts/bootstrap/`

- **`README.md`**: 원격 state 생성 순서, `backend.hcl`, identity/management 적용 순서, GitHub 시크릿, 네이밍·태그 참고.
- **`bootstrap-state-storage.sh`** (실행 가능): RG·Storage Account·컨테이너·blob 버전 관리·태그; 출력으로 `backend.hcl` 조각(`use_azuread_auth`, `tenant_id`, `subscription_id` 등).

### 2.2 `platform/identity/02-identity-federation`

- Terraform: `azurerm` + `azuread` — Entra 앱, GitHub Actions용 federated credential(브랜치·추가 브랜치 변수), 서비스 프린시플.
- 구독에 **Contributor**(토글 가능), 선택 시 state Storage Account에 **Storage Blob Data Contributor**.
- `backend.tf`(azurerm remote), `backend.hcl.example`, `terraform.tfvars.example`, `.terraform.lock.hcl`.
- **`README.md`**: 적용 순서·출력 → GitHub 시크릿 매핑·워크플로 스모크 안내.

### 2.3 `platform/management/03-policy-governance`

- 구독 정책 할당: **RG에 태그 필수**(기본 태그명 `environment`), **허용 리전**(기본 `koreacentral`).
- RG 이름 패턴은 변수·출력·README로 **문서화만**(맞춤 정책 리소스는 제거하고 기본 제공 정책만 사용).
- `backend.tf`, 예시 파일, `.terraform.lock.hcl`, **`README.md`**.

### 2.4 `stacks/_stack-template`

- 새 스택 복사용 템플릿: provider `default_tags`, `azurerm` backend, 플레이스홀더 `terraform_data`, 예시 변수·`locals` 네이밍 헬퍼.
- **`stacks/README.md`**: 템플릿 용도 안내.

### 2.5 CI / 도구

- **`.github/workflows/platform-bootstrap-ci.yml`**: `terraform fmt -check`, `setup-terraform` 1.14.9, 위 스택에 `init -backend=false` + `validate`; **workflow_dispatch** 시 `azure/login`(OIDC) + `az account show`.
- **`Makefile`**: 잘못 들어간 `jbh` 줄 삭제; `STACK=` 도움말 예시를 `platform/identity/02-identity-federation` 형태로 수정.
- **`platform/README.md`**: Stage 1 스택과 `scripts/bootstrap`, `_stack-template` 안내.

---

## 3. 기타

- 여러 스택에서 생성된 **`.terraform.lock.hcl`** 은 재현 가능한 provider 버전 고정용으로 버전 관리에 포함하는 것을 권장한다.
- 로컬 적용 시: 먼저 부트스트랩 스크립트로 state 저장소를 만든 뒤, 각 스택에서 `backend.hcl`·`terraform.tfvars`를 채우고 apply한다.

---

## 4. 도구 버전 고정 (Terraform)

- **Terraform CLI**: `1.14.9` — 각 스택 `versions.tf`의 `required_version`, 루트 **`.terraform-version`**(tfenv 등), CI **`hashicorp/setup-terraform`** 와 동일하게 맞출 것.
- **Providers**: `hashicorp/azurerm` **`4.69.0`**, `hashicorp/azuread` **`3.8.0`** (identity 스택만 `azuread` 사용).
- 로컬·CI는 **`terraform`** 명령 기준이다 (이전에 쓰이던 OpenTofu/`tofu` 호출은 Makefile·pre-commit·워크플로에서 **terraform** 으로 통일).
- **`.terraform.lock.hcl`** 은 Terraform Registry 기준 해시로 갱신되었다 (`registry.terraform.io/hashicorp/...`).

---

*문서 생성 시점: 저장소 내 변경 이력·대화 내용 기준 통합 요약.*
