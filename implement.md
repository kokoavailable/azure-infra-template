# 구현 이해 가이드 (구조 → 순서 → 이 레포 상태)

바이브 코딩만 하다 보면 “파일은 많은데 전체 그림이 안 잡히는” 상태가 되기 쉽다. 이 문서는 **한 번에 한 덩어리**만 이해하고, **순서대로** 쌓아 올리는 용도다.

---

## 1. 먼저 잡을 큰 덩어리 (4층)

```
┌─────────────────────────────────────────────────────────────┐
│  A. 설계 계약 (문서)     ← 리소스 거의 없음, 원칙·주소·경계 고정   │
└─────────────────────────────────────────────────────────────┘
                              ↓ 적용 순서
┌─────────────────────────────────────────────────────────────┐
│  B. 플랫폼 부트스트랩    ← 인증·state·정책·태깅·RBAC 골격          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  C. 연결성 (글로벌→허브→프라이빗 DNS) ← 이름·경로·피어링·DNS      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  D. 워크로드 스포크      ← env × spoke × 레이어 스택             │
└─────────────────────────────────────────────────────────────┘
```

- **A**가 흔들리면 B·C·D 전부 다시 논의해야 한다.
- **B** 없이 C·D만 가면 매 스택마다 인증·state·태그가 제각각이 된다.
- **C**에서 Private DNS가 정리되기 전에 스포크에 PE만 양산하면 DNS가 꼬인다 (Azure에서 반복해서 말하는 패턴).

---

## 2. 레포 디렉터리와 위 4층 매핑

| 층 | 이 레포에서 주로 어디인가 |
| --- | --- |
| A 설계 | `docs/architecture.md`, `docs/layer-dependency.md`, `docs/dns-strategy.md`, `docs/security-baseline.md`, `docs/stack-conventions.md`, `docs/adr/*` |
| B 부트스트랩 | `scripts/bootstrap/*`, `platform/identity/02-identity-federation`, `platform/management/03-policy-governance`, `stacks/_stack-template` |
| C 연결성 | `platform/connectivity/global/00-dns-public`, `platform/connectivity/kr/koreacentral/hub/*` |
| D 워크로드 | `spokes/<env>/<spoke>/kr/koreacentral/*` |

`platform/shared-services/`는 **허브 연결성과 섞지 않는 공용 런타임/레지스트리** (ACR 등) — C와 역할이 다르다.

---

## 3. 단계별 워크스루 (0 → 10)

각 단계마다 **산출물**과 **완료 기준**만 보면 된다. 구현 세부는 해당 스택 README·모듈을 연다.

### 0단계: 먼저 고정할 것

- **리소스 거의 없음.** 주소 체계, 환경 경계, 배포·DNS·Private Link 원칙을 **문서와 변수 규약**으로 고정.
- **확정 예시:** 환경 `dev` / `stg` / `prod`, 리전 `kr/koreacentral`, 리전당 허브 1개, 스포크 단위(`app-main`, `shared-airflow`, `shared-observability`), CIDR, public DNS 글로벌 / private DNS 허브 중심, PE는 스포크·DNS는 허브 정렬, ingress는 스포크 App GW/WAF, egress·중앙 보안은 허브.

**산출물 (문서 위주)**  
`docs/architecture.md`, `docs/layer-dependency.md`, `docs/dns-strategy.md`, `docs/security-baseline.md`, `docs/stack-conventions.md`

**디렉터리 스켈레톤**  
`platform/connectivity/.../hub/...`, `platform/shared-services/...`, `spokes/<env>/<spoke>/...` — *코드보다 “어디에 무엇이 들어갈지” 경계를 먼저 잡는 단계.*

**이 레포에서의 상태:** 위 문서 반영 + 폴더·스택별 `README.md` 골격까지 반영됨.

---

### 1단계: 플랫폼 최소 부트스트랩

- **네트워크 전에** identity / management / state를 깐다. Landing zone 문서도 connectivity와 분리해서 설명하는 이유와 같다.
- **만드는 것:** 원격 state 저장소, 구독·RG 네이밍 기준, GitHub Actions **OIDC**, 기본 policy/governance, 공통 태깅·RBAC 골격.

**경로**

- `scripts/bootstrap/*` — state용 Storage 등 **최초 수동·CLI 친화** 부트스트랩
- `platform/identity/02-identity-federation` — OIDC 앱·federated credential·SP·RBAC(+ state blob 권한)
- `platform/management/03-policy-governance` — 예: RG 태그 필수, 허용 리전 등 최소 정책
- `stacks/_stack-template` — 새 스택 복사용 템플릿

**목표 한 줄:** “이제부터 모든 스택이 **같은 인증·같은 state·같은 태깅·같은 권한 모델**로 배포된다.”

**완료 기준**

- GitHub Actions에서 OIDC로 Azure 로그인 가능
- remote state 정상 동작
- 최소 정책·태그·권한 베이스라인 적용
- 새 스택 템플릿 재사용 가능

**도구 버전 (이 레포 고정)**  
Terraform CLI **1.14.9**, `azurerm` **4.69.0**, `azuread` **3.8.0** (루트 `.terraform-version`, 각 스택 `versions.tf`)

**이 레포에서의 상태:** 위 경로에 Terraform 코드·CI·Makefile·pre-commit까지 반영됨. **아직 네트워크 스택은 미구현.**

---

### 2단계: 글로벌 연결성 중 **Public DNS만**

- 허브 VNet 전체를 한 번에 만들지 않고, **글로벌 공유 자산**인 public zone부터 분리한다.

**경로:** `platform/connectivity/global/00-dns-public`

**하는 일:** public DNS zone, 기본 레코드 전략, ACME/TXT 검증 흐름, dev/stg/prod FQDN 패턴 확정.

**완료 기준:** zone 생성, 예제·인증 검증 레코드 동작, naming/subdomain 규약 확정.

**이 레포에서의 상태:** 디렉터리·README만 있음 → **다음 구현 후보.**

---

### 3단계: 허브 네트워크 최소형

- 허브를 비대하게 만들지 않는다. **중앙 연결성·피어링 받을 준비·egress 자리·접근 경로**가 핵심.

**경로 예시**

- `platform/connectivity/kr/koreacentral/hub/00-hub-network`
- `platform/connectivity/kr/koreacentral/hub/10-egress-routing-security`
- `platform/connectivity/kr/koreacentral/hub/20-access-ops`

**원칙:** 초반에는 NAT+단순 UDR로 시작하고, 통제 요구가 커지면 Firewall을 넣어도 된다. 다만 나중에 spoke 간·중앙 egress를 **허브 경유**로 모을 계획이면 UDR/Firewall 설계를 처음부터 열어둔다 (peering은 기본 nontransitive).

**완료 기준:** hub VNet, peering 주소 계획, egress 모델, bastion/jump 경로 1개.

**이 레포에서의 상태:** 폴더·README만 있음 → **미구현.**

---

### 4단계: Private DNS와 Private Link 기반

- PE를 먼저 양산하면 DNS가 꼬이기 쉽다. **zone·link·해석 경로**를 먼저.

**경로:** `platform/connectivity/kr/koreacentral/hub/05-private-dns`

**완료 기준:** 허브 기준으로 private zone 관리, 스포크에서 PaaS PE 이름 해석, `nslookup`/`dig`로 사설 IP 확인.

**이 레포에서의 상태:** 미구현.

---

### 5단계: 공용 플랫폼 서비스

- 워크로드 전용이 아닌 **공유 서비스** (ACR, 문서 저장소, dev-tools 등). **허브와 역할을 섞지 않는다.**

**경로**

- `platform/shared-services/nonprod/10-artifact-registry`, `20-docs-publication`, `30-dev-tools`
- `platform/shared-services/prod/...`

**완료 기준:** 이미지 push/pull, 문서 배포, nonprod/prod 분리.

**이 레포에서의 상태:** 폴더·README만 있음 → **미구현.**

---

### 6단계: 첫 스포크는 **dev / app-main 하나만**

- dev·stg·prod를 한꺼번에 병렬로 만들지 않는다. **반복 가능한 패턴** 하나를 완성한다.

**레이어 순서 (의도적으로 edge를 늦게)**

| 순서 | 레이어 | 비고 |
| --- | --- | --- |
| 1 | `00-spoke-network` | |
| 2 | `05-secrets` | |
| 3 | `06-configuration` | |
| 4 | `20-data` | |
| 5 | `30-compute` | |
| 6 | `10-edge` | **ingress를 나중에** — 먼저 사설 안에서 앱이 뜨는지 확인 후 공개 edge |
| 7 | `40-observability` | |

**경로:** `spokes/dev/app-main/kr/koreacentral/...`

**완료 기준:** 스포크 VNet·허브 peering, KV/Config/DB private 연결, 컴퓨트에서 DB 접속, 내부 health OK.

**이 레포에서의 상태:** 폴더·README만 있음 → **미구현.**

---

### 7단계: dev 스포크 **내부 세부 순서**

스포크 하나를 **작은 하위 블록**으로 나눠 적용한다.

| 하위 | 디렉터리 | 하는 일 (요약) |
| --- | --- | --- |
| 7-1 | `00-spoke-network` | VNet, 서브넷(app/data/pe), peering, UDR/NSG |
| 7-2 | `05-secrets` | Key Vault, MI 권한, 비밀·인증서 |
| 7-3 | `06-configuration` | App Configuration, 라벨 전략, KV 참조 |
| 7-4 | `20-data` | PostgreSQL Flexible, Storage, PE, **private DNS 검증** |
| 7-5 | `30-compute` | VMSS 등, 이미지·bootstrap, MI, health extension |
| 7-6 | `10-edge` | App GW/WAF, backend pool, probe, **public DNS와 연결** |
| 7-7 | `40-observability` | 진단 설정, 로그/메트릭/알림, 게이트 |

Peering은 nontransitive이므로 **spoke 간 통신**이 필요하면 허브 경유 vs 직접 연결을 명시적으로 선택한다.

---

### 8단계: shared-service 스포크 분리

- 관측·Airflow 같은 걸 허브에 억지로 넣지 않고 **별도 스포크**로 둔다.

**순서 제안:** dev의 `app-main`이 안정된 뒤 확장.

**폴더 (이 레포 명명)**  
`spokes/stg/shared-observability`, `spokes/stg/shared-airflow`, `spokes/prod/...` 등 — *문서에서 말하는 “nonprod”는 개념적으로 dev+stg 묶음이고, 이 레포는 **환경별 폴더 `dev` / `stg` / `prod`** 로 나뉜다.*

---

### 9단계: stg는 검증판, prod는 재현

- **prod에서 처음 실험하지 않는다.**

**순서:** dev/app-main 안정화 → `stg/app-main`으로 인증서·DNS·롤아웃·롤백·알람 검증 → `prod/app-main`.

---

### 10단계: 나중에 붙일 것 (MVP 이후)

- Azure Virtual Network Manager, subscription vending 자동화, multi-region/GTM, DNS Private Resolver 하이브리드, Firewall 기반 egress 고도화 등 — **규모·요구가 커진 뒤.**

---

## 4. “지금까지 한 변화”를 한 줄로 구조화하면

| 무엇을 했나 | 어디에 대응하나 |
| --- | --- |
| 원칙·주소·허브-스포크·DNS 원칙 문서화 | **0단계 (A층)** |
| `platform/`·`spokes/` 디렉터리와 스택 접두 규약 | **0단계** |
| state 부트스트랩 스크립트 + OIDC + 정책 + 템플릿 + CI | **1단계 (B층)** |
| Terraform 1.14.9 / provider 핀 | **1단계** 도구 계약 |

**아직 안 한 것:** 2단계 이후 실제 리소스 (`00-dns-public`, 허브 네트워크, private DNS, shared-services Terraform, 스포크 스택).

---

## 5. 실제 적용 순서 (이 레포 기준 짧은 체크리스트)

문서와 폴더를 허브-스포크 기준으로 맞춘 뒤, 구현은 대략 이 순서가 자연스럽다.

1. 문서·폴더·네이밍 (0단계 — 이미 반영)
2. `platform/identity`, `platform/management`, `scripts/bootstrap` (1단계 — 코드 반영됨)
3. `platform/connectivity/global/00-dns-public`
4. `platform/connectivity/.../hub/00-hub-network`
5. `platform/connectivity/.../hub/05-private-dns`
6. `platform/shared-services/nonprod/*` (이후 prod)
7. `spokes/dev/app-main/*`
8. `spokes/stg|prod/shared-observability`, `shared-airflow` (필요 시)
9. `spokes/stg/app-main/*` → 검증 후 `spokes/prod/app-main/*`

---

## 6. 읽을 때 추천하는 순서 (멘탈 모델 복구용)

1. `docs/architecture.md` 전체 표 한 번 읽기 (Stage 0 고정값)
2. `docs/layer-dependency.md` — **플랫폼 vs 스포크 적용 순서**
3. `readme2.md` 또는 루트 `change1.md` — 레포 트리와 “무엇이 이미 있나”
4. `platform/identity/.../README.md` → `platform/management/.../README.md` → `scripts/bootstrap/README.md`
5. 구현 들어갈 단계만 해당 **스택 폴더의 README** 열기

이 순서를 유지하면 “파일 나열”이 아니라 **의존성 순서**로 읽게 된다.
