# Management (플랫폼 거버넌스)

이 디렉터리는 **`identity/`와 역할을 나눈 구독 단 플랫폼 운영·규칙** 을 두는 곳이다.

| 영역 | 역할 |
| --- | --- |
| **`identity/`** | **누가** 인프라를 배포하는가 — GitHub Actions OIDC, 서비스 주체, 배포용 RBAC. |
| **`management/`** | **어떤 규칙**으로 리소스를 쓰게 할 것인가 — Azure Policy, 태그·리전 같은 **가드레일**, (문서화된) 네이밍·태그 관례. |

`connectivity/`(허브·피어링), `shared-services/`(공용 서비스)와 달리, 여기 스택들은 **네트워크 토폴로지가 아니라 조직·구독 수준의 통제** 에 집중한다.

## 포함 스택

| 디렉터리 | 하는 일 |
| --- | --- |
| [`03-policy-governance`](03-policy-governance/README.md) | 구독에 Built-in 정책 할당(RG 필수 태그, 허용 리전 등). RG 이름 패턴은 변수·출력과 `docs/naming-conventions.md` 로 정렬(이 스택만으로는 이름 강제 없음). |

번호 `03` 은 저장소 전체 부트스트랩 순서(identity 다음 보조 단계)를 맞추기 위한 것이며, 앞자리 `01`·`02` 를 비워 두었을 수 있다.

## 부트스트랩에서의 순서

1. State 스토리지 ([`scripts/bootstrap`](../../scripts/bootstrap/README.md))
2. `platform/identity/02-identity-federation` (OIDC·배포 주체)
3. **`platform/management/03-policy-governance`** (이 폴더) — 이후 만들어지는 RG·리소스가 기본 규칙을 따르도록 하는 편이 자연스럽다.

CI/로컬에서 Terraform을 돌리는 주체가 이미 있다면, 정책은 그 **이후**에 적용해도 되지만, 워크로드가 늘기 전에 적용하는 것을 권장한다.

## 앞으로 여기에 둘 만한 것 (선택)

같은 “관리·거버넌스” 성격이면 예를 들어 **예산 알림**, **Microsoft Defender for Cloud 연락처/티어**, **진단 설정 수집**(구독 진단) 같은 스택을 추가할 수 있다. 이 저장소에는 아직 디렉터리만 두지 않았다.
