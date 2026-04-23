azure-infra-template/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── layer-dependency.md
│   └── runbook.md
├── modules/
│   ├── naming/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── network/
│   │   └── README.md
│   ├── app_gateway_waf/
│   │   └── README.md
│   ├── vmss_was/
│   │   └── README.md
│   ├── vmss_algo/
│   │   └── README.md
│   ├── postgres_flexible/
│   │   └── README.md
│   ├── monitoring_vm/
│   │   └── README.md
│   ├── jumpbox/
│   │   └── README.md
│   ├── airflow/
│   │   └── README.md
│   └── storage_object/
│       └── README.md
├── stacks/
├── platform/
│   ├── README.md
│   ├── shared/
│   │   ├── 00-dns-public/
│   │   ├── 01-dns-private/
│   │   ├── 02-identity-federation/
│   │   └── 03-policy-governance/
│   ├── nonprod/
│   │   ├── 10-artifact-registry/
│   │   ├── 20-docs-publication/
│   │   └── 30-dev-tools/
│   └── prod/
│       ├── 10-artifact-registry/
│       └── 20-docs-publication/
├── workloads/
│   ├── prod/
│   │   ├── README.md
│   │   ├── global/
│   │   │   ├── 00-foundation/
│   │   │   └── 10-edge/
│   │   └── kr/
│   │       └── koreacentral/
│   │           ├── 00-foundation/
│   │           ├── 05-secrets/
│   │           ├── 06-configuration/
│   │           ├── 10-edge/
│   │           ├── 20-data/
│   │           ├── 30-compute/
│   │           └── 40-observability/
│   ├── stg/
│   │   ├── README.md
│   │   ├── global/
│   │   │   ├── 00-foundation/
│   │   │   └── 10-edge/
│   │   └── kr/
│   │       └── koreacentral/
│   │           ├── 00-foundation/
│   │           ├── 05-secrets/
│   │           ├── 06-configuration/
│   │           ├── 10-edge/
│   │           ├── 20-data/
│   │           ├── 30-compute/
│   │           └── 40-observability/
│   └── dev/
│       ├── README.md
│       └── kr/
│           └── koreacentral/
│               ├── 00-foundation/
│               ├── 05-secrets/
│               ├── 06-configuration/
│               ├── 20-data/
│               └── 30-compute/
├── packer/
│   ├── README.md
│   ├── runtime-base.pkr.hcl
│   └── scripts/
│       ├── alloy.sh
│       ├── azure-cli.sh
│       ├── base.sh
│       ├── docker.sh
│       └── node-exporter.sh
├── scripts/
│   ├── README.md
│   ├── apply.sh
│   ├── deploy.sh
│   └── init-backend.sh
├── ssl/
│   ├── README.md
│   ├── stg.sh
│   ├── dev.sh
│   └── prod.sh
└── examples/