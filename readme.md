azure-infra-template/
├── README.md                          # 아키텍처 다이어그램 + 레이어 설명
├── docs/
│   ├── architecture.md                # 전체 설계 의도
│   ├── layer-dependency.md            # 레이어 간 의존성 흐름
│   └── runbook.md                     # apply 순서, 롤백 등
│
├── modules/                           # 재사용 가능한 단위
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md                  # 모듈별 usage example
│   ├── app_gateway_waf/
│   ├── vmss/
│   ├── postgres_flexible/
│   ├── key_vault/
│   ├── monitoring_vm/
│   └── naming/
│
├── layers/                            # stacks → layers (의도가 명확)
│   ├── 00-foundation/                 # RG, VNet, Subnet, NSG, Identity
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── backend.tf
│   ├── 05-secrets/                    # Key Vault, secret seeding
│   ├── 10-edge/                       # App Gateway, WAF, TLS
│   ├── 20-compute/                    # VMSS, cloud-init
│   ├── 30-data/                       # PostgreSQL Flexible Server
│   └── 40-observability/              # Monitoring VM, Grafana stack
│
├── environments/                      # env별 변수만 분리
│   ├── prod.tfvars
│   ├── stg.tfvars
│   └── dev.tfvars
│
├── packer/                            # Golden image pipeline
│   ├── runtime-base.pkr.hcl
│   └── scripts/
│
├── scripts/                           # Operational tooling
│   ├── apply.sh                       # layer 순서대로 apply
│   ├── deploy.sh
│   └── init-backend.sh
│
└── examples/                          # 보너스: 동작하는 데모
    └── fastapi-otel/