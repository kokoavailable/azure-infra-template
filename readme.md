azure-infra-template/  # Azure 플랫폼 인프라 저장소 루트. OpenTofu 모듈/스택, Packer 이미지, 운영/SSL 보조 스크립트, 예제, 문서를 한곳에 두는 최상위 경계.
├── .editorconfig              # 에디터 공통 규칙. 들여쓰기·줄바꿈·인코딩 등을 맞춰 포맷 편차를 줄인다.
├── .gitignore                 # Git 미추적 규칙. 로컬 상태·캐시·비밀·빌드 산출물 등 커밋하지 않을 경로를 정의한다.
├── .pre-commit-config.yaml    # pre-commit 훅. fmt/lint/정적 검사 등으로 커밋 직전 품질 게이트를 건다.
├── Makefile                   # 반복 작업 진입점. tofu/packer/문서 등 자주 쓰는 명령을 짧은 타깃으로 묶는다.
├── LICENSE                    # 라이선스 고지. 코드·문서 사용 조건을 명시한다.
├── README.md                  # 저장소 메인 문서. 구조, 사용 흐름, 실행 순서, 원칙을 처음 보는 사람이 따라갈 수 있게 정리한다.
│
├── .github/  # GitHub 전용 메타 디렉터리. CI/CD 워크플로, 이슈/PR 템플릿 등 GitHub 플랫폼 기능을 담는 경계.
│   └── workflows/  # GitHub Actions 워크플로 집합. 검증, 계획, 적용, 이미지 빌드, 문서 체크를 자동화하는 CI/CD 경계.
│       ├── tofu-fmt.yml  # OpenTofu 코드 포맷 검사/정렬 워크플로. 스타일 불일치를 조기에 차단하는 역할.
│       ├── tofu-validate.yml  # OpenTofu 구문 및 기본 유효성 검증 워크플로. plan 이전에 구성 오류를 잡는 역할.
│       ├── tofu-plan.yml  # OpenTofu 실행 계획 생성 워크플로. 변경 영향과 drift를 리뷰 가능한 형태로 노출하는 역할.
│       ├── tofu-apply.yml  # OpenTofu 실제 반영 워크플로. 승인된 계획을 대상 환경에 적용하는 배포 경계.
│       ├── packer-validate.yml  # Packer 템플릿 유효성 검증 워크플로. 이미지 빌드 전 문법/구성 오류를 차단.
│       ├── packer-build.yml  # Packer 이미지 빌드 워크플로. 런타임/모니터링 베이스 이미지를 생성하는 역할.
│       └── docs-link-check.yml  # 문서 링크 무결성 검사 워크플로. README/문서 내 깨진 링크를 자동 점검.
│
├── bootstrap/  # 플랫폼/환경 배포 전에 한 번 또는 매우 드물게 수행하는 부트스트랩 자산 모음 디렉터리.
│   ├── README.md  # bootstrap 디렉터리의 목적, 실행 순서, 주의사항, 재실행 정책 설명 문서.
│   ├── state-backend/  # OpenTofu/Terraform remote state 저장소를 최초 생성하는 부트스트랩 스택.
│   │   ├── README.md  # state backend 스택의 역할, 생성 대상, 실행 방법 설명 문서.
│   │   ├── main.tf  # state backend용 핵심 리소스(Storage Account, Container 등) 생성 정의.
│   │   ├── variables.tf  # state backend 생성에 필요한 입력 변수 선언.
│   │   ├── outputs.tf  # 생성된 backend 자원 이름, id, container 정보 등 출력 정의.
│   │   └── terraform.tfvars.example  # state backend 부트스트랩 실행 시 사용할 입력값 예시 파일.
│   └── oidc-seed/  # 선택적 부트스트랩 디렉터리. GitHub Actions OIDC, Federated Identity Credential, 초기 Service Principal 연결용 seed 자산.
│       ├── README.md  # OIDC seed의 목적, 적용 시점, 이후 본 스택으로 이관할 범위 설명 문서.
│       ├── main.tf  # 초기 OIDC/FIC/SP 또는 관련 IAM 리소스 생성 정의.
│       ├── variables.tf  # GitHub org/repo, subject, audience, tenant 등 입력 변수 선언.
│       ├── outputs.tf  # 생성된 principal/client id, federated credential 식별값 등 출력 정의.
│       └── terraform.tfvars.example  # OIDC seed 실행 시 사용할 입력값 예시 파일.
│
├── docs/  # 설계 문서 루트. 코드가 아니라 구조/원칙/운영 절차/ADR/다이어그램 같은 설명 책임을 분리하는 문서 경계.
│   ├── architecture.md  # 전체 아키텍처 설명서. 제어면/데이터면, 주요 리소스 관계, 트래픽 흐름을 설명하는 문서.
│   ├── layer-dependency.md  # 레이어 의존성 문서. foundation→secrets→configuration→edge→data→compute→observability 같은 적용 순서와 경계를 정의.
│   ├── runbook.md  # 운영 런북. 배포, 롤백, 장애 대응, 점검 절차를 단계별로 정리하는 문서.
│   ├── naming-conventions.md  # 리소스/모듈/스택 네이밍 규칙 문서. 이름 충돌과 가독성 저하를 막는 기준점.
│   ├── stack-conventions.md  # 스택 작성 규칙 문서. provider/backend/locals/variables/main/outputs 파일 배치 원칙과 책임 분리를 정의.
│   ├── release-strategy.md  # 배포 전략 문서. golden image, rollout, rollback, 배치 정책, 승격 흐름 같은 릴리스 원칙을 설명.
│   ├── observability.md  # 관측성 설계 문서. metrics/logs/traces, 수집 경로, 대시보드, 알람 책임을 정리.
│   ├── dns-strategy.md  # DNS 설계 문서. public/private DNS 분리, 중앙화 원칙, zone/link/forwarding 경계를 설명.
│   ├── security-baseline.md  # 보안 기준선 문서. RBAC, 네트워크 차단, 비밀관리, 진단로그, 정책/거버넌스 최소 기준을 정의.
│   ├── adr/  # ADR(Architecture Decision Record) 모음. 주요 구조적 선택과 그 이유, 대안, 결과를 장기 보존하는 경계.
│   │   ├── 0001-platform-vs-workloads.md  # 플랫폼 스택과 워크로드 스택을 왜 분리했는지 기록한 ADR.
│   │   ├── 0002-vmss-flex-and-health-model.md  # VMSS Flex 채택 여부와 health model 설계를 기록한 ADR.
│   │   ├── 0003-compute-gallery-golden-image.md  # Azure Compute Gallery 기반 golden image 전략을 기록한 ADR.
│   │   ├── 0004-private-dns-centralization.md  # Private DNS 중앙화 원칙과 링크 전략을 기록한 ADR.
│   │   └── 0005-prod-vs-nonprod-boundaries.md  # prod/nonprod 분리 수준과 공용/전용 리소스 경계를 기록한 ADR.
│   └── diagrams/  # 아키텍처 그림 원본 보관소. 문서 삽입용 draw.io 다이어그램 소스 파일을 두는 경계.
│       ├── control-plane.drawio  # 제어면 다이어그램 원본. IaC, CI/CD, 이미지 빌드, 정책 적용 흐름을 시각화.
│       ├── data-plane.drawio  # 데이터면 다이어그램 원본. 외부 요청, L7/L4, 앱, 데이터 저장소 흐름을 시각화.
│       └── rollout-flow.drawio  # 롤링 배포/롤백 플로우 다이어그램 원본.
│
├── modules/  # 재사용 가능한 OpenTofu 모듈 모음. 스택에서 직접 리소스를 흩뿌리지 않고 책임 단위별로 캡슐화하는 경계.
│   ├── _module-template/  # 신규 모듈 생성용 템플릿. 표준 파일 배치와 테스트 골격을 제공하는 시작점.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── data.tf  # 외부/기존 리소스 조회용 data source 정의 파일. 생성 책임이 아니라 참조 책임을 갖는 경계.
│   │   ├── moved.tf  # 리팩터링 시 리소스 주소 변경을 `moved` 블록으로 기록하는 파일. state를 안전하게 이어가기 위한 목적의 분리 파일.
│   │   ├── examples/  # 모듈 사용 예제 모음. 소비자가 최소 구성으로 모듈 사용법을 이해하는 경계.
│   │   │   └── basic/  # 가장 단순한 예제 디렉터리. 모듈의 최소 사용 패턴을 보여주는 샘플.
│   │   │       ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   │       ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   │       └── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── key_vault/  # Key Vault 모듈. 비밀/인증서 저장소와 네트워크/RBAC/진단설정을 캡슐화하는 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── vault.tf  # Key Vault 본체 리소스 정의 파일. 저장소 생성과 핵심 속성 책임을 가짐.
│   │   ├── network_acls.tf  # Key Vault 네트워크 ACL 정의 파일. public 접근, subnet 허용, 기본 차단 정책 책임.
│   │   ├── role_assignments.tf  # 해당 모듈 리소스에 필요한 RBAC 부여 파일. 액세스 제어 책임을 분리.
│   │   ├── private_endpoint.tf  # Private Endpoint 연결 정의 파일. 서비스 노출을 private path로 제한하는 네트워크 경계.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   ├── secrets.tf  # Key Vault secret 생성/등록 책임 파일. 비밀 데이터 객체만 다루는 경계.
│   │   ├── certificates.tf  # Key Vault certificate 객체 정의 파일. 인증서 수명주기 책임을 분리.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── app_configuration/  # App Configuration 모듈. 비밀이 아닌 런타임 설정값과 Key Vault reference를 관리하는 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── store.tf  # App Configuration store 본체 생성 파일.
│   │   ├── key_values.tf  # App Configuration key-value 항목 정의 파일. 비밀이 아닌 설정값 책임.
│   │   ├── keyvault_references.tf  # App Configuration의 Key Vault reference 항목 정의 파일. secret 값 자체가 아니라 참조만 관리하는 경계.
│   │   ├── role_assignments.tf  # 해당 모듈 리소스에 필요한 RBAC 부여 파일. 액세스 제어 책임을 분리.
│   │   ├── private_endpoint.tf  # Private Endpoint 연결 정의 파일. 서비스 노출을 private path로 제한하는 네트워크 경계.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── naming/  # 이름 생성 모듈. 환경/리전/워크로드 기준의 일관된 naming 결과를 다른 모듈에 공급하는 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   └── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │
│   ├── network/  # 네트워크 모듈. VNet, subnet, NSG, route table, NAT, DNS link 같은 네트워크 기반을 묶는 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── vnet.tf  # VNet 본체와 주소 공간 정의 파일.
│   │   ├── subnets.tf  # 서브넷 정의 파일. 워크로드/PE/게이트웨이 용도별 subnet 경계를 분리.
│   │   ├── nsg.tf  # NSG 규칙 정의 파일. 네트워크 허용/차단 정책 책임.
│   │   ├── route_tables.tf  # 사용자 정의 라우팅 정의 파일. 아웃바운드/허브 경로 제어 책임.
│   │   ├── nat_gateway.tf  # NAT Gateway 연결 정의 파일. 고정 아웃바운드 egress 책임.
│   │   ├── private_dns_links.tf  # Private DNS zone과 VNet 링크 정의 파일.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── app_gateway_waf/  # Application Gateway + WAF 모듈. 공인 진입점, WAF 정책, 리스너/라우팅/프로브를 관리하는 L7 엣지 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── public_ip.tf  # App Gateway 등에 붙는 Public IP 리소스 정의 파일.
│   │   ├── waf_policy.tf  # WAF 정책 정의 파일. 룰셋, 예외, 모드 책임.
│   │   ├── gateway.tf  # Application Gateway 본체 정의 파일.
│   │   ├── listeners.tf  # 호스트/포트/TLS listener 정의 파일.
│   │   ├── backend_pools.tf  # 백엔드 풀 정의 파일. VMSS/ILB/FQDN 대상 집합 책임.
│   │   ├── http_settings.tf  # 백엔드 HTTP 설정 정의 파일. 포트, 프로토콜, 쿠키, 타임아웃, 프로브 연결 책임.
│   │   ├── probes.tf  # 헬스 프로브 정의 파일. readiness 판단 경계.
│   │   ├── routing_rules.tf  # 리스너와 백엔드를 묶는 라우팅 규칙 파일.
│   │   ├── rewrite_rules.tf  # 헤더/URL 재작성 규칙 파일.
│   │   ├── ssl_policy.tf  # TLS 정책/암호군 설정 파일.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── vmss_was/  # WAS용 VMSS 모듈. 이미지, 확장, 헬스, 오토스케일, 인스턴스 수리, 부트스트랩을 묶는 컴퓨트 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── image.tf  # VMSS가 참조할 이미지 정의/조회 파일. Azure Compute Gallery 버전 참조 책임.
│   │   ├── vmss.tf  # VM Scale Set 본체 정의 파일. SKU, 인스턴스 수, 업그레이드 정책 등 핵심 책임.
│   │   ├── extensions.tf  # VMSS/VM 확장 정의 파일. 모니터링/헬스/스크립트 확장 책임.
│   │   ├── health.tf  # 애플리케이션 헬스와 업그레이드 게이팅 관련 설정 파일.
│   │   ├── autoscale.tf  # 오토스케일 규칙 정의 파일.
│   │   ├── instance_repair.tf  # 자동 인스턴스 수리 설정 파일.
│   │   ├── role_assignments.tf  # 해당 모듈 리소스에 필요한 RBAC 부여 파일. 액세스 제어 책임을 분리.
│   │   ├── bootstrap.tftpl  # 초기 부트스트랩 스크립트 템플릿. 런타임 설치/환경 설정/서비스 기동 역할.
│   │   ├── cloud-init.tftpl  # cloud-init 사용자 데이터 템플릿. VM 첫 부팅 시 초기화 책임.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── vmss_algo/  # 알고리즘/배치성 워크로드용 VMSS 모듈. WAS와 분리된 별도 스케일셋 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── image.tf  # VMSS가 참조할 이미지 정의/조회 파일. Azure Compute Gallery 버전 참조 책임.
│   │   ├── vmss.tf  # VM Scale Set 본체 정의 파일. SKU, 인스턴스 수, 업그레이드 정책 등 핵심 책임.
│   │   ├── extensions.tf  # VMSS/VM 확장 정의 파일. 모니터링/헬스/스크립트 확장 책임.
│   │   ├── health.tf  # 애플리케이션 헬스와 업그레이드 게이팅 관련 설정 파일.
│   │   ├── autoscale.tf  # 오토스케일 규칙 정의 파일.
│   │   ├── instance_repair.tf  # 자동 인스턴스 수리 설정 파일.
│   │   ├── role_assignments.tf  # 해당 모듈 리소스에 필요한 RBAC 부여 파일. 액세스 제어 책임을 분리.
│   │   ├── bootstrap.tftpl  # 초기 부트스트랩 스크립트 템플릿. 런타임 설치/환경 설정/서비스 기동 역할.
│   │   ├── cloud-init.tftpl  # cloud-init 사용자 데이터 템플릿. VM 첫 부팅 시 초기화 책임.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── postgres_flexible/  # Azure Database for PostgreSQL Flexible Server 모듈. DB 서버/DB/백업/네트워크 설정을 캡슐화.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── server.tf  # PostgreSQL Flexible Server 본체 정의 파일.
│   │   ├── databases.tf  # 논리 DB 생성 파일. 서버 내부 데이터베이스 경계.
│   │   ├── firewall.tf  # DB 방화벽/IP 허용 규칙 정의 파일.
│   │   ├── private_endpoint.tf  # Private Endpoint 연결 정의 파일. 서비스 노출을 private path로 제한하는 네트워크 경계.
│   │   ├── private_dns.tf  # DB용 private DNS zone 또는 레코드 연동 책임 파일.
│   │   ├── backups.tf  # 백업/보존/복구 관련 설정 파일.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── monitoring_vm/  # 관측용 VM 모듈. Prometheus/Alloy 등 수집기용 전용 VM과 설정 템플릿을 묶는 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── vm.tf  # 단일 VM 본체 정의 파일. monitoring_vm/jumpbox에서 주 리소스 책임.
│   │   ├── disks.tf  # 추가 디스크/데이터 디스크 정의 파일.
│   │   ├── networking.tf  # 모듈 내부 NIC/IP/서브넷 연결 등 네트워킹 책임 파일.
│   │   ├── role_assignments.tf  # 해당 모듈 리소스에 필요한 RBAC 부여 파일. 액세스 제어 책임을 분리.
│   │   ├── cloud-init.tftpl  # cloud-init 사용자 데이터 템플릿. VM 첫 부팅 시 초기화 책임.
│   │   ├── alloy-config.tftpl  # Grafana Alloy 설정 템플릿.
│   │   ├── prometheus-config.tftpl  # Prometheus 설정 템플릿.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── jumpbox/  # 운영 접속용 Jumpbox 모듈. 관리 접속 경로와 Entra 로그인 설정을 분리하는 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── vm.tf  # 단일 VM 본체 정의 파일. monitoring_vm/jumpbox에서 주 리소스 책임.
│   │   ├── networking.tf  # 모듈 내부 NIC/IP/서브넷 연결 등 네트워킹 책임 파일.
│   │   ├── entra_login.tf  # Entra ID 기반 로그인/확장 설정 파일.
│   │   ├── role_assignments.tf  # 해당 모듈 리소스에 필요한 RBAC 부여 파일. 액세스 제어 책임을 분리.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   ├── airflow/  # Airflow 런타임 모듈. 워크플로 오케스트레이션용 컴퓨트/스토리지/네트워킹을 묶는 경계.
│   │   ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│   │   ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│   │   ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│   │   ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│   │   ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│   │   ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│   │   ├── compute.tf  # Airflow 컴퓨트 리소스 정의 파일.
│   │   ├── storage.tf  # Airflow용 스토리지 리소스 정의 파일.
│   │   ├── networking.tf  # 모듈 내부 NIC/IP/서브넷 연결 등 네트워킹 책임 파일.
│   │   ├── role_assignments.tf  # 해당 모듈 리소스에 필요한 RBAC 부여 파일. 액세스 제어 책임을 분리.
│   │   ├── private_endpoint.tf  # Private Endpoint 연결 정의 파일. 서비스 노출을 private path로 제한하는 네트워크 경계.
│   │   ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│   │   └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│   │       └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│   │
│   └── storage_object/  # Object Storage 모듈. Storage Account, container, lifecycle, private connectivity, CMK를 관리하는 경계.
│       ├── README.md  # 모듈 사용 문서. 입력값, 출력값, 예제, 경계, 의존 조건을 설명하는 파일.
│       ├── versions.tf  # OpenTofu/provider 버전 제약과 required providers를 선언하는 파일.
│       ├── main.tf  # 모듈의 주 진입점. 하위 tf 파일을 묶는 중심 파일이며, 파일 분할이 있더라도 모듈 대표 엔트리 역할을 함.
│       ├── variables.tf  # 모듈 입력 변수 정의 파일. 외부에서 주입받는 값과 검증 규칙을 선언.
│       ├── outputs.tf  # 모듈 출력 정의 파일. 상위 스택이나 다른 모듈에 노출할 식별자/속성을 정리.
│       ├── locals.tf  # 중간 계산값과 파생 이름/태그/기본값을 정리하는 파일.
│       ├── account.tf  # Storage Account 본체 정의 파일.
│       ├── containers.tf  # Blob container 정의 파일.
│       ├── lifecycle.tf  # 스토리지 lifecycle 관리 규칙 정의 파일.
│       ├── private_endpoint.tf  # Private Endpoint 연결 정의 파일. 서비스 노출을 private path로 제한하는 네트워크 경계.
│       ├── private_dns.tf  # DB용 private DNS zone 또는 레코드 연동 책임 파일.
│       ├── cmk.tf  # Customer Managed Key(CMK) 연동 정의 파일.
│       ├── diagnostics.tf  # 진단 로그/메트릭 전송 설정 파일. Log Analytics/Storage/Event Hub 연계 책임.
│       └── tests/  # 모듈 테스트 디렉터리. `tofu test`용 검증 시나리오를 두는 경계.
│           └── basic.tftest.hcl  # 기본 테스트 시나리오. `tofu test`로 실제 인프라를 띄워 assertions를 검증하는 테스트 파일.
│
├── stacks/  # 스택 템플릿/조합 패턴 보관소. 실제 환경 스택을 만들기 위한 공통 골격과 composition 예시를 두는 경계.
│   ├── README.md  # 스택 레이어 작성 규칙과 템플릿 사용법을 설명하는 문서.
│   ├── _stack-template/  # 신규 스택 생성용 표준 골격. provider/backend/variables/main/outputs 구조를 일관되게 시작하기 위한 템플릿.
│   │   ├── README.md  # 스택 설명 문서. 스택 목적, 의존성, 적용 순서, 입력값 설명.
│   │   ├── versions.tf  # OpenTofu/provider 버전 잠금 파일.
│   │   ├── providers.tf  # 대상 subscription/tenant/provider alias 설정 파일.
│   │   ├── backend.tf  # 원격 상태 저장소 구성 파일.
│   │   ├── backend.hcl.example  # backend 초기화에 넣을 값 예시 파일.
│   │   ├── data.tf  # 기존 공용 리소스 조회용 data source 파일.
│   │   ├── locals.tf  # 이 스택 내부 계산값/태그/이름 파생값 정의 파일.
│   │   ├── variables.tf  # 스택 입력 변수 정의 파일.
│   │   ├── main.tf  # 스택 주 리소스/모듈 호출 엔트리 파일.
│   │   ├── outputs.tf  # 스택 출력값 정의 파일.
│   │   ├── moved.tf  # 리팩터링 후 주소 이전 기록 파일.
│   │   ├── imports.tf  # 기존 리소스 import 선언 파일.
│   │   └── terraform.tfvars.example  # 이 스택에 주입할 변수값 예시 파일.
│   └── compositions/  # 반복 조합 패턴 모음. 여러 모듈/스택을 묶어 공통 배치 예시를 제시하는 경계.
│       ├── shared-networking/  # 공유 네트워킹 조합 예시 디렉터리. DNS/VNet/기초 네트워크 구성 패턴의 묶음.
│       ├── regional-workload-base/  # 리전별 워크로드 기본 조합 예시 디렉터리.
│       └── vmss-rollout-base/  # VMSS 롤아웃/업그레이드 기본 조합 예시 디렉터리.
│
├── platform/  # 플랫폼 공용 인프라 영역. 특정 앱 런타임과 분리된 shared services, delivery tooling, policy를 담는 상위 경계.
│   ├── README.md  # 플랫폼 영역 안내서. shared/nonprod/prod 플랫폼 스택의 목적과 경계를 설명.
│   ├── shared/  # 모든 환경이 공통으로 의존할 수 있는 shared 플랫폼 스택 모음.
│   │   ├── 00-dns-public/  # 공용 authoritative DNS 관리 스택. 외부 공개 zone/record 책임.
│   │   │   ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│   │   │   ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │   ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│   │   │   ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│   │   │   ├── backend.hcl.example  # backend 초기화 예시 파일.
│   │   │   ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│   │   │   ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│   │   │   ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│   │   │   ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│   │   │   └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│   │   ├── 01-dns-private/  # 사설 DNS 중앙 관리 스택. Private DNS zone/link/resolution 책임.
│   │   │   ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│   │   │   ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │   ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│   │   │   ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│   │   │   ├── backend.hcl.example  # backend 초기화 예시 파일.
│   │   │   ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│   │   │   ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│   │   │   ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│   │   │   ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│   │   │   └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│   │   ├── 02-identity-federation/  # OIDC/Federation 기반 CI/CD identity 관리 스택. GitHub Actions 같은 외부 워크로드 아이덴티티 연계 책임.
│   │   │   ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│   │   │   ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │   ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│   │   │   ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│   │   │   ├── backend.hcl.example  # backend 초기화 예시 파일.
│   │   │   ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│   │   │   ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│   │   │   ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│   │   │   ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│   │   │   └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│   │   └── 03-policy-governance/  # 정책/거버넌스 스택. Azure Policy, guardrail, 태깅 강제 같은 조직 수준 제어 책임.
│   │       ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│   │       ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│   │       ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│   │       ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│   │       ├── backend.hcl.example  # backend 초기화 예시 파일.
│   │       ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│   │       ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│   │       ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│   │       ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│   │       └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│   │
│   ├── nonprod/  # dev/stg 등 비프로덕션 전용 플랫폼 스택 모음. 실험/내부도구/공용 비prod 서비스 경계.
│   │   ├── 10-artifact-registry/  # 이미지/아티팩트 저장소 스택. ACR 같은 전달 체인 공용 저장소 책임.
│   │   │   ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│   │   │   ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │   ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│   │   │   ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│   │   │   ├── backend.hcl.example  # backend 초기화 예시 파일.
│   │   │   ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│   │   │   ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│   │   │   ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│   │   │   ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│   │   │   └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│   │   ├── 20-docs-publication/  # 문서 공개/배포 스택. OAS/static docs 호스팅 책임.
│   │   │   ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│   │   │   ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │   ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│   │   │   ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│   │   │   ├── backend.hcl.example  # backend 초기화 예시 파일.
│   │   │   ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│   │   │   ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│   │   │   ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│   │   │   ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│   │   │   └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│   │   └── 30-dev-tools/  # 개발자 도구 스택. 비prod 편의용 도구, 실험성 공용 유틸리티 책임.
│   │       ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│   │       ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│   │       ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│   │       ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│   │       ├── backend.hcl.example  # backend 초기화 예시 파일.
│   │       ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│   │       ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│   │       ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│   │       ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│   │       └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│   │
│   └── prod/  # 프로덕션용 플랫폼 스택 모음. nonprod와 분리해 권한/비용/리스크를 차단하는 경계.
│       ├── 10-artifact-registry/  # 이미지/아티팩트 저장소 스택. ACR 같은 전달 체인 공용 저장소 책임.
│       │   ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│       │   ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│       │   ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│       │   ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│       │   ├── backend.hcl.example  # backend 초기화 예시 파일.
│       │   ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│       │   ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│       │   ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│       │   ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│       │   └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│       └── 20-docs-publication/  # 문서 공개/배포 스택. OAS/static docs 호스팅 책임.
│           ├── README.md  # 해당 플랫폼 스택 설명 문서. 목적, 의존성, 운영 범위, 입력값을 기술.
│           ├── versions.tf  # 플랫폼 스택의 OpenTofu/provider 버전 제약 파일.
│           ├── providers.tf  # 플랫폼 스택 provider 설정 파일.
│           ├── backend.tf  # 플랫폼 스택 원격 상태 저장소 설정 파일.
│           ├── backend.hcl.example  # backend 초기화 예시 파일.
│           ├── locals.tf  # 스택 내부 계산값/공통 태그/이름 파생값 정의 파일.
│           ├── variables.tf  # 플랫폼 스택 입력 변수 정의 파일.
│           ├── main.tf  # 플랫폼 스택 주 리소스/모듈 호출 파일.
│           ├── outputs.tf  # 플랫폼 스택 출력값 정의 파일.
│           └── terraform.tfvars.example  # 플랫폼 스택 변수 예시 파일.
│
├── workloads/  # 앱 런타임 인프라 영역. 실제 서비스가 올라가는 환경별/리전별 스택을 담는 상위 경계.
│   ├── README.md  # 워크로드 영역 안내서. prod/stg/dev 구조와 레이어 순서를 설명.
│   ├── prod/  # 프로덕션 워크로드 스택 루트. 가장 엄격한 분리/안정성 기준을 적용하는 경계.
│   │   ├── README.md  # 해당 환경(workloads 하위) 설명 문서. 환경 목적, 차이점, 운영 원칙 설명.
│   │   ├── global/  # 리전 공통 혹은 멀티리전 공용 레이어 디렉터리. global traffic/공용 foundation 같은 전역 책임 경계.
│   │   │   ├── 00-foundation/  # 워크로드 기초 인프라 레이어. RG, VNet, 서브넷, 공용 MI 같은 선행 기반 책임.
│   │   │   │   ├── README.md  # 해당 환경(workloads 하위) 설명 문서. 환경 목적, 차이점, 운영 원칙 설명.
│   │   │   │   ├── versions.tf  # 해당 워크로드 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │   │   ├── providers.tf  # 해당 워크로드 스택 provider 설정 파일.
│   │   │   │   ├── backend.tf  # 해당 워크로드 스택 상태 저장소 설정 파일.
│   │   │   │   ├── backend.hcl.example  # backend 입력 예시 파일.
│   │   │   │   ├── locals.tf  # 스택 내부 파생값 정의 파일.
│   │   │   │   ├── variables.tf  # 스택 입력 변수 정의 파일.
│   │   │   │   ├── main.tf  # 스택에서 모듈을 조합해 실제 리소스를 생성하는 엔트리 파일.
│   │   │   │   ├── outputs.tf  # 스택 출력값 정의 파일.
│   │   │   │   └── terraform.tfvars.example  # 스택 변수 예시 파일.
│   │   │   └── 10-edge/  # 엣지 레이어. App Gateway, WAF, Public ingress, DNS 연결 책임.
│   │   │       ├── README.md  # 해당 환경(workloads 하위) 설명 문서. 환경 목적, 차이점, 운영 원칙 설명.
│   │   │       ├── versions.tf  # 해당 워크로드 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │       ├── providers.tf  # 해당 워크로드 스택 provider 설정 파일.
│   │   │       ├── backend.tf  # 해당 워크로드 스택 상태 저장소 설정 파일.
│   │   │       ├── backend.hcl.example  # backend 입력 예시 파일.
│   │   │       ├── locals.tf  # 스택 내부 파생값 정의 파일.
│   │   │       ├── variables.tf  # 스택 입력 변수 정의 파일.
│   │   │       ├── main.tf  # 스택에서 모듈을 조합해 실제 리소스를 생성하는 엔트리 파일.
│   │   │       ├── outputs.tf  # 스택 출력값 정의 파일.
│   │   │       └── terraform.tfvars.example  # 스택 변수 예시 파일.
│   │   └── kr/  # 국가 단위 구분 디렉터리. 리전 상위 분류 경계.
│   │        └── koreacentral/  # Azure Korea Central 리전 스택 묶음 디렉터리.
│   │            ├── 00-foundation/  # 워크로드 기초 인프라 레이어. 다른 레이어가 의존하는 네트워크/아이덴티티 기반 책임.
│   │            │   ├── README.md  # 이 레이어의 책임, 선행/후행 의존성, apply 순서, 주의사항 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 최소/고정 버전 선언.
│   │            │   ├── providers.tf  # azurerm provider 설정과 features, subscription 연결 정의.
│   │            │   ├── locals.tf  # 환경명, 리전명, 네이밍 규칙, 공통 태그 같은 파생 로컬값 정의.
│   │            │   ├── data.tf  # 다른 스택의 remote state, 현재 subscription/client 정보 조회용 data source 정의.
│   │            │   ├── variables.tf  # 이 레이어가 외부로부터 받는 입력 변수 선언.
│   │            │   ├── outputs.tf  # 다음 레이어에서 참조할 RG/VNet/Subnet/MI 등의 출력값 정의.
│   │            │   ├── backend.hcl  # remote state backend 접속 설정 분리 파일.
│   │            │   ├── resource_groups.tf  # 리소스 그룹 생성 정의.
│   │            │   ├── network.tf  # VNet과 주소 공간 등 네트워크 골격 정의.
│   │            │   ├── subnets.tf  # 애플리케이션, 데이터, 관측성 등 목적별 서브넷 정의.
│   │            │   ├── nsg.tf  # 서브넷/워크로드 보호를 위한 NSG 및 보안 규칙 정의.
│   │            │   └── identities.tf  # 이후 레이어와 워크로드가 재사용할 Managed Identity 정의.
│   │            ├── 05-secrets/  # 비밀/인증서 레이어. secret, certificate, key 저장과 접근 통제 책임.
│   │            │   ├── README.md  # Key Vault 레이어의 역할, 보안 원칙, 운영 절차 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # Key Vault 이름, 태그, 공통 접두사 등 로컬값 정의.
│   │            │   ├── data.tf  # foundation 출력값, 현재 tenant/client 정보 등 조회 정의.
│   │            │   ├── variables.tf  # vault SKU, 접근 주체, private endpoint 여부 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # Key Vault ID, URI, 인증서 secret id 등 출력값 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── key_vault.tf  # Key Vault 본체와 기본 보안 옵션 정의.
│   │            │   ├── access_control.tf  # RBAC 또는 access policy를 통한 접근 권한 정의.
│   │            │   ├── certificates.tf  # TLS 인증서 import, 참조, lifecycle 관련 정의.
│   │            │   └── private_endpoints.tf  # Key Vault private endpoint 및 사설 접근 연결 정의.
│   │            ├── 06-configuration/  # 런타임 설정 레이어. 비secret 설정과 feature flag 관리 책임.
│   │            │   ├── README.md  # App Configuration 사용 범위와 label 전략, 운영 규칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 설정 키 접두사, 공통 label, 네이밍 규칙 정의.
│   │            │   ├── data.tf  # foundation/secrets 출력값과 현재 컨텍스트 조회 정의.
│   │            │   ├── variables.tf  # store 이름, 환경 라벨, 초기 key/value 입력 변수 선언.
│   │            │   ├── outputs.tf  # App Configuration endpoint, id 등 출력값 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── app_configuration.tf  # App Configuration store 본체 정의.
│   │            │   ├── key_values.tf  # 애플리케이션 런타임 key/value 설정 정의.
│   │            │   └── feature_flags.tf  # 기능 토글과 점진 배포용 feature flag 정의.
│   │            ├── 10-edge/  # 엣지 레이어. 외부 트래픽 진입, TLS 종료, WAF, 라우팅 책임.
│   │            │   ├── README.md  # 엣지 구성의 역할, 도메인 연결, 인증서/헬스체크 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 도메인명, listener 명명 규칙, 공통 태그 정의.
│   │            │   ├── data.tf  # foundation/subnet, secrets/cert, compute backend 정보 조회 정의.
│   │            │   ├── variables.tf  # 도메인, 백엔드 포트, probe 경로 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # App Gateway ID, 공인 IP, 엔드포인트 정보 출력 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── public_ip.tf  # App Gateway 등 엣지 리소스용 공인 IP 정의.
│   │            │   ├── application_gateway.tf  # Application Gateway 본체와 기본 설정 정의.
│   │            │   ├── waf_policy.tf  # WAF 정책, rule set, 예외 처리 정의.
│   │            │   ├── listeners.tf  # HTTP/HTTPS listener와 frontend port/host binding 정의.
│   │            │   ├── routing_rules.tf  # path 기반 또는 host 기반 라우팅 규칙 정의.
│   │            │   └── health_probes.tf  # 백엔드 상태 확인용 헬스 프로브와 관련 설정 정의.
│   │            ├── 20-data/  # 데이터 레이어. 상태 저장소와 영속 데이터 서비스 책임.
│   │            │   ├── README.md  # PostgreSQL/Storage 계층의 책임, 백업/보안/연결 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # DB/스토리지 네이밍, 태그, 환경별 파생값 정의.
│   │            │   ├── data.tf  # foundation 네트워크, secrets 참조값 등 조회 정의.
│   │            │   ├── variables.tf  # DB SKU, storage replication, container 목록 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # DB fqdn, storage account name/id 등 출력값 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── postgres.tf  # PostgreSQL Flexible Server 및 관련 설정 정의.
│   │            │   ├── storage_accounts.tf  # Blob/File 등을 담는 Storage Account 정의.
│   │            │   ├── storage_containers.tf  # 애플리케이션이 사용할 컨테이너/버킷 성격의 논리 저장소 정의.
│   │            │   └── private_endpoints.tf  # 데이터 계층의 private endpoint 및 사설 연결 정의.
│   │            ├── 30-observability-platform/  # 관측 플랫폼 레이어. 관측 시스템 자체를 띄우는 책임.
│   │            │   ├── README.md  # 메트릭/로그/트레이스 플랫폼 구조와 운영 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 관측 플랫폼 리소스 네이밍, 태그, 공통 파라미터 정의.
│   │            │   ├── data.tf  # foundation 네트워크, data 스토리지, secrets 값 등 조회 정의.
│   │            │   ├── variables.tf  # VM 크기, 저장 용량, retention 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # Grafana URL, Loki/Tempo/Prometheus endpoint 등 출력 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── monitoring_vm.tf  # 관측 스택을 구동할 모니터링 VM 또는 기반 컴퓨트 정의.
│   │            │   ├── grafana.tf  # Grafana 인스턴스 및 접근 설정 정의.
│   │            │   ├── prometheus.tf  # Prometheus 서버 및 스크랩 저장 설정 정의.
│   │            │   ├── loki.tf  # Loki 로그 저장/조회 시스템 정의.
│   │            │   └── tempo.tf  # Tempo 분산 추적 저장 시스템 정의.
│   │            ├── 40-compute/  # 워크로드 컴퓨트 레이어. 실제 서비스와 배치 런타임 실행 책임.
│   │            │   ├── README.md  # WAS/Algo/Airflow 등 런타임 계층의 책임과 배포 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 컴퓨트 리소스 이름, 이미지 태그, 공통 태그 정의.
│   │            │   ├── data.tf  # foundation/data/secrets/configuration 출력값 조회 정의.
│   │            │   ├── variables.tf  # VMSS 크기, 인스턴스 수, 이미지 버전 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # 백엔드 풀 연결 대상, private IP, identity 정보 등 출력 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── vmss_was.tf  # 웹/API 애플리케이션용 VMSS 정의.
│   │            │   ├── vmss_algo.tf  # 알고리즘/배치/특수 처리용 VMSS 정의.
│   │            │   ├── airflow.tf  # 워크플로 오케스트레이션용 Airflow 런타임 정의.
│   │            │   ├── autoscale.tf  # CPU/메트릭 기반 오토스케일 규칙 정의.
│   │            │   └── extensions.tf  # cloud-init, VM extension, 부트스트랩/에이전트 설정 정의.
│   │            └── 45-observability-wiring/  # 관측 연결 레이어. 워크로드를 관측 플랫폼에 붙이는 책임.
│   │                ├── README.md  # 수집 경로, 대시보드, 알람, 진단 연결 구조 설명 문서.
│   │                ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │                ├── providers.tf  # provider 설정 정의.
│   │                ├── locals.tf  # 관측 연결용 공통 이름, 알람 prefix, 태그 정의.
│   │                ├── data.tf  # compute/edge/data/observability-platform 출력값 조회 정의.
│   │                ├── variables.tf  # 알람 임계치, 대시보드 설정, 수집 대상 입력 변수 선언.
│   │                ├── outputs.tf  # 생성된 알람, 대시보드, 진단 연결 결과 출력 정의.
│   │                ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │                ├── scrape_targets.tf  # Prometheus가 수집할 대상과 scrape job 연결 정의.
│   │                ├── log_shipping.tf  # Promtail/Alloy/Agent 등을 통한 로그 수집 연결 정의.
│   │                ├── tracing.tf  # OpenTelemetry/Tempo 등 트레이스 전송 연결 정의.
│   │                ├── dashboards.tf  # Grafana 대시보드 프로비저닝 및 기본 시각화 정의.
│   │                └── alerts.tf  # 메트릭/로그 기반 알람과 통지 규칙 정의.
│   │
│   ├── stg/  # 스테이징 워크로드 스택 루트. 프로덕션 검증 전 단계 환경 경계.
│   │   ├── README.md  # 해당 환경(workloads 하위) 설명 문서. 환경 목적, 차이점, 운영 원칙 설명.
│   │   ├── global/  # 리전 공통 혹은 멀티리전 공용 레이어 디렉터리. global traffic/공용 foundation 같은 전역 책임 경계.
│   │   │   ├── 00-foundation/  # 워크로드 기초 인프라 레이어. RG, VNet, 서브넷, 공용 MI 같은 선행 기반 책임.
│   │   │   │   ├── README.md  # 해당 환경(workloads 하위) 설명 문서. 환경 목적, 차이점, 운영 원칙 설명.
│   │   │   │   ├── versions.tf  # 해당 워크로드 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │   │   ├── providers.tf  # 해당 워크로드 스택 provider 설정 파일.
│   │   │   │   ├── backend.tf  # 해당 워크로드 스택 상태 저장소 설정 파일.
│   │   │   │   ├── backend.hcl.example  # backend 입력 예시 파일.
│   │   │   │   ├── locals.tf  # 스택 내부 파생값 정의 파일.
│   │   │   │   ├── variables.tf  # 스택 입력 변수 정의 파일.
│   │   │   │   ├── main.tf  # 스택에서 모듈을 조합해 실제 리소스를 생성하는 엔트리 파일.
│   │   │   │   ├── outputs.tf  # 스택 출력값 정의 파일.
│   │   │   │   └── terraform.tfvars.example  # 스택 변수 예시 파일.
│   │   │   └── 10-edge/  # 엣지 레이어. App Gateway, WAF, Public ingress, DNS 연결 책임.
│   │   │       ├── README.md  # 해당 환경(workloads 하위) 설명 문서. 환경 목적, 차이점, 운영 원칙 설명.
│   │   │       ├── versions.tf  # 해당 워크로드 스택의 OpenTofu/provider 버전 제약 파일.
│   │   │       ├── providers.tf  # 해당 워크로드 스택 provider 설정 파일.
│   │   │       ├── backend.tf  # 해당 워크로드 스택 상태 저장소 설정 파일.
│   │   │       ├── backend.hcl.example  # backend 입력 예시 파일.
│   │   │       ├── locals.tf  # 스택 내부 파생값 정의 파일.
│   │   │       ├── variables.tf  # 스택 입력 변수 정의 파일.
│   │   │       ├── main.tf  # 스택에서 모듈을 조합해 실제 리소스를 생성하는 엔트리 파일.
│   │   │       ├── outputs.tf  # 스택 출력값 정의 파일.
│   │   │       └── terraform.tfvars.example  # 스택 변수 예시 파일.
│   │   └── kr/  # 국가 단위 구분 디렉터리. 리전 상위 분류 경계.
│   │        └── koreacentral/  # Azure Korea Central 리전 스택 묶음 디렉터리.
│   │            ├── 00-foundation/  # 워크로드 기초 인프라 레이어. 다른 레이어가 의존하는 네트워크/아이덴티티 기반 책임.
│   │            │   ├── README.md  # 이 레이어의 책임, 선행/후행 의존성, apply 순서, 주의사항 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 최소/고정 버전 선언.
│   │            │   ├── providers.tf  # azurerm provider 설정과 features, subscription 연결 정의.
│   │            │   ├── locals.tf  # 환경명, 리전명, 네이밍 규칙, 공통 태그 같은 파생 로컬값 정의.
│   │            │   ├── data.tf  # 다른 스택의 remote state, 현재 subscription/client 정보 조회용 data source 정의.
│   │            │   ├── variables.tf  # 이 레이어가 외부로부터 받는 입력 변수 선언.
│   │            │   ├── outputs.tf  # 다음 레이어에서 참조할 RG/VNet/Subnet/MI 등의 출력값 정의.
│   │            │   ├── backend.hcl  # remote state backend 접속 설정 분리 파일.
│   │            │   ├── resource_groups.tf  # 리소스 그룹 생성 정의.
│   │            │   ├── network.tf  # VNet과 주소 공간 등 네트워크 골격 정의.
│   │            │   ├── subnets.tf  # 애플리케이션, 데이터, 관측성 등 목적별 서브넷 정의.
│   │            │   ├── nsg.tf  # 서브넷/워크로드 보호를 위한 NSG 및 보안 규칙 정의.
│   │            │   └── identities.tf  # 이후 레이어와 워크로드가 재사용할 Managed Identity 정의.
│   │            ├── 05-secrets/  # 비밀/인증서 레이어. secret, certificate, key 저장과 접근 통제 책임.
│   │            │   ├── README.md  # Key Vault 레이어의 역할, 보안 원칙, 운영 절차 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # Key Vault 이름, 태그, 공통 접두사 등 로컬값 정의.
│   │            │   ├── data.tf  # foundation 출력값, 현재 tenant/client 정보 등 조회 정의.
│   │            │   ├── variables.tf  # vault SKU, 접근 주체, private endpoint 여부 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # Key Vault ID, URI, 인증서 secret id 등 출력값 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── key_vault.tf  # Key Vault 본체와 기본 보안 옵션 정의.
│   │            │   ├── access_control.tf  # RBAC 또는 access policy를 통한 접근 권한 정의.
│   │            │   ├── certificates.tf  # TLS 인증서 import, 참조, lifecycle 관련 정의.
│   │            │   └── private_endpoints.tf  # Key Vault private endpoint 및 사설 접근 연결 정의.
│   │            ├── 06-configuration/  # 런타임 설정 레이어. 비secret 설정과 feature flag 관리 책임.
│   │            │   ├── README.md  # App Configuration 사용 범위와 label 전략, 운영 규칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 설정 키 접두사, 공통 label, 네이밍 규칙 정의.
│   │            │   ├── data.tf  # foundation/secrets 출력값과 현재 컨텍스트 조회 정의.
│   │            │   ├── variables.tf  # store 이름, 환경 라벨, 초기 key/value 입력 변수 선언.
│   │            │   ├── outputs.tf  # App Configuration endpoint, id 등 출력값 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── app_configuration.tf  # App Configuration store 본체 정의.
│   │            │   ├── key_values.tf  # 애플리케이션 런타임 key/value 설정 정의.
│   │            │   └── feature_flags.tf  # 기능 토글과 점진 배포용 feature flag 정의.
│   │            ├── 10-edge/  # 엣지 레이어. 외부 트래픽 진입, TLS 종료, WAF, 라우팅 책임.
│   │            │   ├── README.md  # 엣지 구성의 역할, 도메인 연결, 인증서/헬스체크 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 도메인명, listener 명명 규칙, 공통 태그 정의.
│   │            │   ├── data.tf  # foundation/subnet, secrets/cert, compute backend 정보 조회 정의.
│   │            │   ├── variables.tf  # 도메인, 백엔드 포트, probe 경로 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # App Gateway ID, 공인 IP, 엔드포인트 정보 출력 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── public_ip.tf  # App Gateway 등 엣지 리소스용 공인 IP 정의.
│   │            │   ├── application_gateway.tf  # Application Gateway 본체와 기본 설정 정의.
│   │            │   ├── waf_policy.tf  # WAF 정책, rule set, 예외 처리 정의.
│   │            │   ├── listeners.tf  # HTTP/HTTPS listener와 frontend port/host binding 정의.
│   │            │   ├── routing_rules.tf  # path 기반 또는 host 기반 라우팅 규칙 정의.
│   │            │   └── health_probes.tf  # 백엔드 상태 확인용 헬스 프로브와 관련 설정 정의.
│   │            ├── 20-data/  # 데이터 레이어. 상태 저장소와 영속 데이터 서비스 책임.
│   │            │   ├── README.md  # PostgreSQL/Storage 계층의 책임, 백업/보안/연결 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # DB/스토리지 네이밍, 태그, 환경별 파생값 정의.
│   │            │   ├── data.tf  # foundation 네트워크, secrets 참조값 등 조회 정의.
│   │            │   ├── variables.tf  # DB SKU, storage replication, container 목록 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # DB fqdn, storage account name/id 등 출력값 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── postgres.tf  # PostgreSQL Flexible Server 및 관련 설정 정의.
│   │            │   ├── storage_accounts.tf  # Blob/File 등을 담는 Storage Account 정의.
│   │            │   ├── storage_containers.tf  # 애플리케이션이 사용할 컨테이너/버킷 성격의 논리 저장소 정의.
│   │            │   └── private_endpoints.tf  # 데이터 계층의 private endpoint 및 사설 연결 정의.
│   │            ├── 30-observability-platform/  # 관측 플랫폼 레이어. 관측 시스템 자체를 띄우는 책임.
│   │            │   ├── README.md  # 메트릭/로그/트레이스 플랫폼 구조와 운영 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 관측 플랫폼 리소스 네이밍, 태그, 공통 파라미터 정의.
│   │            │   ├── data.tf  # foundation 네트워크, data 스토리지, secrets 값 등 조회 정의.
│   │            │   ├── variables.tf  # VM 크기, 저장 용량, retention 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # Grafana URL, Loki/Tempo/Prometheus endpoint 등 출력 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── monitoring_vm.tf  # 관측 스택을 구동할 모니터링 VM 또는 기반 컴퓨트 정의.
│   │            │   ├── grafana.tf  # Grafana 인스턴스 및 접근 설정 정의.
│   │            │   ├── prometheus.tf  # Prometheus 서버 및 스크랩 저장 설정 정의.
│   │            │   ├── loki.tf  # Loki 로그 저장/조회 시스템 정의.
│   │            │   └── tempo.tf  # Tempo 분산 추적 저장 시스템 정의.
│   │            ├── 40-compute/  # 워크로드 컴퓨트 레이어. 실제 서비스와 배치 런타임 실행 책임.
│   │            │   ├── README.md  # WAS/Algo/Airflow 등 런타임 계층의 책임과 배포 원칙 설명 문서.
│   │            │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │            │   ├── providers.tf  # provider 설정 정의.
│   │            │   ├── locals.tf  # 컴퓨트 리소스 이름, 이미지 태그, 공통 태그 정의.
│   │            │   ├── data.tf  # foundation/data/secrets/configuration 출력값 조회 정의.
│   │            │   ├── variables.tf  # VMSS 크기, 인스턴스 수, 이미지 버전 등 입력 변수 선언.
│   │            │   ├── outputs.tf  # 백엔드 풀 연결 대상, private IP, identity 정보 등 출력 정의.
│   │            │   ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │            │   ├── vmss_was.tf  # 웹/API 애플리케이션용 VMSS 정의.
│   │            │   ├── vmss_algo.tf  # 알고리즘/배치/특수 처리용 VMSS 정의.
│   │            │   ├── airflow.tf  # 워크플로 오케스트레이션용 Airflow 런타임 정의.
│   │            │   ├── autoscale.tf  # CPU/메트릭 기반 오토스케일 규칙 정의.
│   │            │   └── extensions.tf  # cloud-init, VM extension, 부트스트랩/에이전트 설정 정의.
│   │            └── 45-observability-wiring/  # 관측 연결 레이어. 워크로드를 관측 플랫폼에 붙이는 책임.
│   │                ├── README.md  # 수집 경로, 대시보드, 알람, 진단 연결 구조 설명 문서.
│   │                ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│   │                ├── providers.tf  # provider 설정 정의.
│   │                ├── locals.tf  # 관측 연결용 공통 이름, 알람 prefix, 태그 정의.
│   │                ├── data.tf  # compute/edge/data/observability-platform 출력값 조회 정의.
│   │                ├── variables.tf  # 알람 임계치, 대시보드 설정, 수집 대상 입력 변수 선언.
│   │                ├── outputs.tf  # 생성된 알람, 대시보드, 진단 연결 결과 출력 정의.
│   │                ├── backend.hcl  # 이 스택의 remote state backend 설정.
│   │                ├── scrape_targets.tf  # Prometheus가 수집할 대상과 scrape job 연결 정의.
│   │                ├── log_shipping.tf  # Promtail/Alloy/Agent 등을 통한 로그 수집 연결 정의.
│   │                ├── tracing.tf  # OpenTelemetry/Tempo 등 트레이스 전송 연결 정의.
│   │                ├── dashboards.tf  # Grafana 대시보드 프로비저닝 및 기본 시각화 정의.
│   │                └── alerts.tf  # 메트릭/로그 기반 알람과 통지 규칙 정의.
│   │
│   └── dev/  # 개발 워크로드 스택 루트. 빠른 변경, 낮은 비용, 짧은 피드백 루프를 우선하는 환경 경계.
│       ├── README.md  # dev 환경 목적, stg/prod와의 차이, 비용 절감 원칙, 생략된 구성 설명 문서.
│       └── kr/  # 국가 단위 구분 디렉터리. 리전 상위 분류 경계.
│           └── koreacentral/  # Azure Korea Central 리전의 dev workload 스택 묶음 디렉터리.
│               ├── 00-foundation/  # dev 워크로드 기초 인프라 레이어. 최소 네트워크, 서브넷, NSG, MI 등 선행 기반 책임.
│               │   ├── README.md  # foundation 레이어 책임, 축약된 dev 구성, apply 순서 설명 문서.
│               │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│               │   ├── providers.tf  # azurerm provider 설정과 features 정의.
│               │   ├── locals.tf  # env/region, dev 네이밍 규칙, 공통 태그 정의.
│               │   ├── data.tf  # subscription/client config, 공용 state 참조 등 data source 정의.
│               │   ├── variables.tf  # foundation 레이어 입력 변수 선언.
│               │   ├── outputs.tf  # RG/VNet/Subnet/MI 등 하위 레이어용 출력 정의.
│               │   ├── backend.hcl  # remote state backend 설정 파일.
│               │   ├── stack.auto.tfvars.example  # dev foundation 입력값 예시 파일.
│               │   ├── resource_groups.tf  # dev 리소스 그룹 생성 정의.
│               │   ├── network.tf  # dev용 VNet 및 address space 정의.
│               │   ├── subnets.tf  # compute/data 용도의 최소 서브넷 정의.
│               │   ├── nsg.tf  # dev 보안 규칙 정의.
│               │   └── identities.tf  # dev 워크로드용 Managed Identity 정의.
│               ├── 05-secrets/  # dev 비밀/인증서 레이어. 실험용 secret/certificate 저장과 접근 통제 책임.
│               │   ├── README.md  # dev secrets 레이어 책임, stg/prod 대비 축약 포인트 설명 문서.
│               │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│               │   ├── providers.tf  # azurerm provider 설정 정의.
│               │   ├── locals.tf  # Key Vault 네이밍, 공통 태그, dev 파생값 정의.
│               │   ├── data.tf  # foundation 출력값, tenant 정보 등 조회 정의.
│               │   ├── variables.tf  # vault 설정, 접근 주체, seed secret 입력 변수 선언.
│               │   ├── outputs.tf  # Key Vault ID, URI, secret 참조값 출력 정의.
│               │   ├── backend.hcl  # remote state backend 설정 파일.
│               │   ├── stack.auto.tfvars.example  # dev secrets 입력값 예시 파일.
│               │   ├── key_vault.tf  # dev Key Vault 본체 정의.
│               │   ├── access_control.tf  # RBAC 또는 access policy 정의.
│               │   └── secrets.tf  # 개발용 seed secret 및 공통 secret 정의.
│               ├── 06-configuration/  # dev 런타임 설정 레이어. 비secret 설정과 기능 플래그 관리 책임.
│               │   ├── README.md  # dev configuration 책임, 실험용 설정 원칙, label 전략 설명 문서.
│               │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│               │   ├── providers.tf  # azurerm provider 설정 정의.
│               │   ├── locals.tf  # 설정 키 prefix, label, 공통 태그 정의.
│               │   ├── data.tf  # foundation/secrets 출력값 조회 정의.
│               │   ├── variables.tf  # App Configuration 이름, key/value, label 입력 변수 선언.
│               │   ├── outputs.tf  # App Configuration endpoint, id 등 출력 정의.
│               │   ├── backend.hcl  # remote state backend 설정 파일.
│               │   ├── stack.auto.tfvars.example  # dev configuration 입력값 예시 파일.
│               │   ├── app_configuration.tf  # App Configuration store 본체 정의.
│               │   ├── key_values.tf  # 개발용 key/value 설정 정의.
│               │   └── feature_flags.tf  # 실험/검증용 feature flag 정의.
│               ├── 20-data/  # dev 데이터 레이어. 낮은 비용의 DB/Storage 등 상태 저장소 책임.
│               │   ├── README.md  # dev 데이터 계층 책임, 비용 절감 설정, 운영 제한사항 설명 문서.
│               │   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│               │   ├── providers.tf  # azurerm provider 설정 정의.
│               │   ├── locals.tf  # DB/Storage 네이밍, 태그, 파생값 정의.
│               │   ├── data.tf  # foundation/secrets 출력값 조회 정의.
│               │   ├── variables.tf  # DB SKU, storage 옵션, container 목록 등 입력 변수 선언.
│               │   ├── outputs.tf  # DB endpoint, storage 정보 출력 정의.
│               │   ├── backend.hcl  # remote state backend 설정 파일.
│               │   ├── stack.auto.tfvars.example  # dev data 입력값 예시 파일.
│               │   ├── postgres.tf  # dev용 PostgreSQL 정의. 필요 시 HA 없이 단순 SKU 사용.
│               │   ├── storage_accounts.tf  # dev Storage Account 정의.
│               │   ├── storage_containers.tf  # 개발용 Blob container 정의.
│               │   └── diagnostic_settings.tf  # 최소 수준의 데이터 계층 진단 설정 정의.
│               └── 30-compute/  # dev 컴퓨트 레이어. 빠른 테스트와 반복 개발을 위한 런타임 실행 책임.
│                   ├── README.md  # dev compute 책임, 배포 방식, 축약된 런타임 구성 설명 문서.
│                   ├── versions.tf  # OpenTofu/Terraform 및 provider 버전 선언.
│                   ├── providers.tf  # azurerm provider 설정 정의.
│                   ├── locals.tf  # 이미지 태그, 네이밍 규칙, 공통 태그 정의.
│                   ├── data.tf  # foundation/secrets/configuration/data 출력값 조회 정의.
│                   ├── variables.tf  # VM 크기, 인스턴스 수, 이미지 버전 등 입력 변수 선언.
│                   ├── outputs.tf  # 런타임 엔드포인트, private IP, identity 등 출력 정의.
│                   ├── backend.hcl  # remote state backend 설정 파일.
│                   ├── stack.auto.tfvars.example  # dev compute 입력값 예시 파일.
│                   ├── vmss_was.tf  # 웹/API 애플리케이션용 VMSS 또는 단일 compute 런타임 정의.
│                   ├── vmss_worker.tf  # 필요 시 비동기 작업/배치 처리용 워커 런타임 정의.
│                   ├── autoscale.tf  # dev 환경에 필요한 최소 오토스케일 규칙 정의.
│                   ├── extensions.tf  # cloud-init, Custom Script Extension, 에이전트 설치 정의.
│                   ├── identities.tf  # 컴퓨트 전용 Managed Identity 정의.
│                   └── diagnostic_settings.tf  # 최소 수준의 컴퓨트 계층 진단 설정 정의.
│
├── packer/  # 이미지 빌드 경계. 런타임/모니터링용 golden image를 Packer로 만드는 영역.
│   ├── README.md  # Packer 사용법, 빌드 절차, 변수 설명 문서.
│   ├── versions.pkr.hcl  # Packer required plugins/버전 제약 선언 파일.
│   ├── variables.pkr.hcl  # Packer 입력 변수 정의 파일.
│   ├── locals.pkr.hcl  # Packer 내부 계산값 정의 파일.
│   ├── sources.pkr.hcl  # 빌드 소스 정의 파일. Azure builder, base image, 갤러리 대상 등 소스 책임.
│   ├── build-runtime-base.pkr.hcl  # 애플리케이션 런타임 베이스 이미지 빌드 정의 파일.
│   ├── build-monitoring-base.pkr.hcl  # 모니터링용 베이스 이미지 빌드 정의 파일.
│   ├── dev.auto.pkrvars.hcl.example  # dev 이미지 빌드 변수 예시 파일.
│   ├── stg.auto.pkrvars.hcl.example  # stg 이미지 빌드 변수 예시 파일.
│   ├── prod.auto.pkrvars.hcl.example  # prod 이미지 빌드 변수 예시 파일.
│   ├── manifests/  # Packer 빌드 결과 메타데이터 보관 디렉터리. 어떤 빌드가 어떤 산출물을 만들었는지 추적하는 경계.
│   │   ├── runtime-base.manifest.json  # Packer manifest 산출물. 빌드된 아티팩트 목록과 메타데이터를 기록하는 JSON 파일.
│   │   └── monitoring-base.manifest.json  # Packer manifest 산출물. 빌드된 아티팩트 목록과 메타데이터를 기록하는 JSON 파일.
│   └── scripts/  # 이미지 빌드 프로비저닝 스크립트 디렉터리. 베이스 이미지 내부에 설치/정리 작업을 수행하는 경계.
│       ├── base.sh  # OS 공통 베이스 설정 스크립트.
│       ├── azure-cli.sh  # Azure CLI 설치/설정 스크립트.
│       ├── docker.sh  # Docker 엔진 및 관련 런타임 설치 스크립트.
│       ├── alloy.sh  # Grafana Alloy 설치/기본 설정 스크립트.
│       ├── node-exporter.sh  # Prometheus node_exporter 설치 스크립트.
│       ├── cleanup.sh  # 이미지 빌드 후 캐시/임시파일 정리 스크립트.
│       └── validate.sh  # 이미지 내부 사전 검증 스크립트. 필요한 바이너리/서비스 존재 여부 확인 역할.
│
├── scripts/  # 운영 보조 스크립트 루트. tofu/packer/deploy/bootstrap/docs 관련 반복 명령을 저장하는 경계.
│   ├── README.md  # 스크립트 사용법 문서. 언제 어떤 스크립트를 쓰는지 설명.
│   ├── bootstrap/  # 초기 세팅 스크립트 디렉터리. 백엔드/구독/OIDC 같은 1회성 또는 드문 초기화를 담당.
│   │   ├── init-backend.sh  # 원격 상태 저장소 초기화 스크립트.
│   │   ├── init-subscriptions.sh  # 구독/기초 설정 초기화 스크립트.
│   │   └── init-oidc-federation.sh  # OIDC federation 초기 설정 스크립트.
│   ├── tofu/  # OpenTofu 실행 래퍼 스크립트 디렉터리.
│   │   ├── fmt.sh  # tofu fmt 래퍼 스크립트.
│   │   ├── validate.sh  # tofu validate 또는 packer validate 래퍼 스크립트.
│   │   ├── plan.sh  # tofu plan 래퍼 스크립트.
│   │   ├── apply.sh  # tofu apply 래퍼 스크립트.
│   │   ├── destroy.sh  # tofu destroy 래퍼 스크립트.
│   │   └── output-summary.sh  # tofu outputs를 요약/가공하는 스크립트.
│   ├── packer/  # Packer 실행 래퍼 스크립트 디렉터리.
│   │   ├── validate.sh  # 이미지 내부 사전 검증 스크립트. 필요한 바이너리/서비스 존재 여부 확인 역할.
│   │   ├── build-runtime-base.sh  # 런타임 베이스 이미지 빌드 래퍼 스크립트.
│   │   └── publish-to-gallery.sh  # 빌드 결과를 Azure Compute Gallery에 게시하는 스크립트.
│   ├── deploy/  # 배포/롤백 보조 스크립트 디렉터리.
│   │   ├── deploy.sh  # 배포 시작 오케스트레이션 스크립트.
│   │   ├── rollout-status.sh  # 롤아웃 진행 상태 점검 스크립트.
│   │   ├── rollback.sh  # 롤백 수행 스크립트.
│   │   └── smoke-test.sh  # 배포 직후 기본 smoke test 스크립트.
│   └── docs/  # 문서/트리 생성 보조 스크립트 디렉터리.
│       └── render-tree.sh  # 저장소 구조 트리를 문서용으로 렌더링하는 스크립트.
│
├── ssl/  # TLS 보조 스크립트 영역. 인증서 발급/동기화/환경별 설정을 저장하는 경계.
│   ├── README.md  # SSL/TLS 운영 방법 문서.
│   ├── common.sh  # 공통 함수/환경 로딩 로직 스크립트.
│   ├── dev.sh  # dev 인증서 처리 진입 스크립트.
│   ├── stg.sh  # stg 인증서 처리 진입 스크립트.
│   ├── prod.sh  # prod 인증서 처리 진입 스크립트.
│   ├── env/  # 환경별 TLS 변수 예시 디렉터리.
│   │   ├── dev.env.example  # dev 환경 TLS 관련 환경변수 예시 파일.
│   │   ├── stg.env.example  # stg 환경 TLS 관련 환경변수 예시 파일.
│   │   └── prod.env.example  # prod 환경 TLS 관련 환경변수 예시 파일.
│   └── nginx/  # Nginx 연계 보조 스크립트 디렉터리. Key Vault에서 인증서를 동기화하고 Nginx를 재적용하는 운영 경계.
│       ├── sync-nginx-tls-from-keyvault.sh  # Key Vault의 인증서를 Nginx용 PEM/KEY 파일로 동기화하는 스크립트.
│       └── reload-nginx.sh  # 인증서 갱신 후 Nginx 설정 재적용/리로드 스크립트.
│
├── examples/  # 예제 조합 루트. 특정 시나리오별 최소/대표 구성을 보여주는 샘플 경계.
│   ├── single-region-dev/  # 단일 리전 dev 예제 디렉터리.
│   ├── stg-public-edge/  # stg에서 public edge를 포함한 예제 디렉터리.
│   ├── prod-single-region/  # prod 단일 리전 예제 디렉터리.
│   ├── prod-multi-region/  # prod 멀티리전 예제 디렉터리.
│   ├── vmss-was-only/  # WAS VMSS만 최소 구성으로 사용하는 예제 디렉터리.
│   └── docs-publication/  # 문서 퍼블리케이션만 분리한 예제 디렉터리.
│
└── templates/  # 문서 템플릿 모음. README/런북 섹션 자동 생성에 쓰는 템플릿 경계.
    ├── stack-readme.md.tmpl  # 스택 README 생성 템플릿.
    ├── module-readme.md.tmpl  # 모듈 README 생성 템플릿.
    └── runbook-section.md.tmpl  # 런북 섹션 생성 템플릿.
