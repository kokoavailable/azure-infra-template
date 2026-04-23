# 레포 디렉터리 레이아웃 (목표 트리)

Stage 0에서 고정한 주소 체계·환경 경계·DNS/Private Link 원칙은 **`docs/architecture.md`**, 스택 접두사와 경로 규약은 **`docs/stack-conventions.md`**, 적용 순서는 **`docs/layer-dependency.md`** 를 기준으로 한다.

## 현재 상태

- **`platform/`**, **`spokes/`**: 디렉터리가 존재하며 스택별 **`README.md`** 만 두었다. OpenTofu/Terraform 파일(`versions.tf`, `main.tf`, …)은 스택 구현 시 `stack-conventions.md` 에 맞춰 추가한다.
- **`modules/`**, **`stacks/`**, **`packer/`**, **`scripts/`**, **`ssl/`**, **`templates/`** 등은 아직 없어도 되며, 필요 시 같은 수준의 트리로 추가하면 된다.
- 아래에서 `identity` / `03-policy-governance` / `00-dns-public` 하위에 적힌 `.tf` · `terraform.tfvars.example` 는 **목표 예시**(full stack)이고, 현재 저장소에는 동일 경로에 README 위주로 맞춰 두었다.

---

```
azure-infra-template/
├── .editorconfig
├── .gitignore
├── .pre-commit-config.yaml
├── Makefile
├── LICENSE
├── README.md
│
├── .github/
├── docs/
├── modules/                    # (예정) 재사용 모듈
├── stacks/                     # (예정) 보조 스택 또는 조합
│   ├── README.md
│   ├── _stack-template/
│   └── compositions/
│
├── platform/
│   ├── README.md
│   │
│   ├── identity/
│   │   └── 02-identity-federation/
│   │       ├── README.md
│   │       ├── versions.tf
│   │       ├── providers.tf
│   │       ├── backend.tf
│   │       ├── backend.hcl.example
│   │       ├── locals.tf
│   │       ├── variables.tf
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars.example
│   │
│   ├── management/
│   │   └── 03-policy-governance/
│   │       ├── README.md
│   │       ├── versions.tf
│   │       ├── providers.tf
│   │       ├── backend.tf
│   │       ├── backend.hcl.example
│   │       ├── locals.tf
│   │       ├── variables.tf
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars.example
│   │
│   ├── connectivity/
│   │   ├── global/
│   │   │   └── 00-dns-public/
│   │   │       ├── README.md
│   │   │       ├── versions.tf
│   │   │       ├── providers.tf
│   │   │       ├── backend.tf
│   │   │       ├── backend.hcl.example
│   │   │       ├── locals.tf
│   │   │       ├── variables.tf
│   │   │       ├── main.tf
│   │   │       ├── outputs.tf
│   │   │       └── terraform.tfvars.example
│   │   │
│   │   └── kr/
│   │       └── koreacentral/
│   │           └── hub/
│   │               ├── 00-hub-network/
│   │               ├── 05-private-dns/
│   │               ├── 10-egress-routing-security/
│   │               └── 20-access-ops/
│   │
│   └── shared-services/
│       ├── nonprod/
│       │   ├── README.md
│       │   ├── 10-artifact-registry/
│       │   ├── 20-docs-publication/
│       │   └── 30-dev-tools/
│       └── prod/
│           ├── README.md
│           ├── 10-artifact-registry/
│           └── 20-docs-publication/
│
├── spokes/
│   ├── README.md
│   │
│   ├── prod/
│   │   ├── app-main/
│   │   │   └── kr/
│   │   │       └── koreacentral/
│   │   │           ├── 00-spoke-network/
│   │   │           ├── 05-secrets/
│   │   │           ├── 06-configuration/
│   │   │           ├── 10-edge/
│   │   │           ├── 20-data/
│   │   │           ├── 30-compute/
│   │   │           └── 40-observability/
│   │   │
│   │   ├── shared-observability/
│   │   │   └── kr/
│   │   │       └── koreacentral/
│   │   │           ├── 00-spoke-network/
│   │   │           ├── 30-compute/
│   │   │           └── 40-observability/
│   │   │
│   │   └── shared-airflow/
│   │       └── kr/
│   │           └── koreacentral/
│   │               ├── 00-spoke-network/
│   │               ├── 05-secrets/
│   │               ├── 20-data/
│   │               └── 30-compute/
│   │
│   ├── stg/
│   │   ├── app-main/
│   │   │   └── kr/
│   │   │       └── koreacentral/
│   │   │           ├── 00-spoke-network/
│   │   │           ├── 05-secrets/
│   │   │           ├── 06-configuration/
│   │   │           ├── 10-edge/
│   │   │           ├── 20-data/
│   │   │           ├── 30-compute/
│   │   │           └── 40-observability/
│   │   │
│   │   ├── shared-observability/
│   │   │   └── kr/
│   │   │       └── koreacentral/
│   │   │           ├── 00-spoke-network/
│   │   │           ├── 30-compute/
│   │   │           └── 40-observability/
│   │   │
│   │   └── shared-airflow/
│   │       └── kr/
│   │           └── koreacentral/
│   │               ├── 00-spoke-network/
│   │               ├── 05-secrets/
│   │               ├── 20-data/
│   │               └── 30-compute/
│   │
│   └── dev/
│       └── app-main/
│           └── kr/
│               └── koreacentral/
│                   ├── 00-spoke-network/
│                   ├── 05-secrets/
│                   ├── 06-configuration/
│                   ├── 10-edge/
│                   ├── 20-data/
│                   └── 30-compute/
│
├── packer/
├── scripts/
├── ssl/
├── examples/
└── templates/
```

각 스택 폴더에는 현재 **`README.md`** 가 있다. 위 트리의 `.tf` 목록은 스택을 채울 때의 **파일 세트 목표**이다.
