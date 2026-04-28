# 00-dns-public

글로벌 플랫폼 소유의 **공용 authoritative DNS Zone**(apex)과 선택적 TXT 레코드(ACME·도메인 검증 등)를 관리한다. Private DNS·허브 VNet은 다른 스택이다.

## 파일별 역할

| 파일 | 하는 일 |
| --- | --- |
| `versions.tf` | Terraform CLI·`azurerm` 버전 고정(`implement.md`와 동일). |
| `backend.tf` | 원격 state 백엔드 타입(`azurerm`). 값은 `backend.hcl`. |
| `providers.tf` | `azurerm` provider. |
| `variables.tf` | 구독·테넌트·조직 접두사·apex 도메인(`root_domain_name`)·태그·선택 TXT 맵. |
| `locals.tf` | RG 이름·공통 태그·dev/stg/prod용 FQDN 규약(출력과 동일). |
| `main.tf` | RG, `azurerm_dns_zone`, 선택 `azurerm_dns_txt_record`. |
| `outputs.tf` | Zone ID·**네임서버 목록**(레지스트라 위임 필수)·환경별 루트 호스트명. |
| `terraform.tfvars.example` | 복사 후 `terraform.tfvars`로 사용. |
| `backend.hcl.example` | state `key` 예시. |

## FQDN 규약

Apex를 `example.com` 이라 하면, 애플리케이션·엣지는 이후 스포크/엣지 스택에서 레코드를 추가하고, 여기서는 **환경 루트 호스트명**만 고정해 둔다:

- `dev.example.com`
- `stg.example.com`
- `prod.example.com`

출력 `fqdn_environment_roots` 와 동일하다.

## 사전 조건

1. 원격 state 백엔드 준비(부트스트랩 스크립트 등).
2. `backend.hcl`에 이 스택 전용 `key`(예: `platform/connectivity/global/00-dns-public.tfstate`).
3. `terraform.tfvars.example` → `terraform.tfvars` 로 복사 후 `root_domain_name`에 **새로 산 등록 도메인** 입력.

**권한:** 대상 구독에서 DNS Zone·RG 생성이 가능해야 한다(예: Contributor 또는 DNS·RG 범위 역할 조합).

## Apply

```bash
cd platform/connectivity/global/00-dns-public
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## 레지스트라에서 할 일

1. Apply 후 `terraform output name_servers` 에 나온 Azure 네임서버를 도메인 구매처(가비아, Route53, Cloudflare 등)에서 **apex NS 위임**으로 등록한다.
2. 위임 전에는 이 Zone으로는 공용 해석이 되지 않는다. 위임 후 전파까지 수 분~수 시간 걸릴 수 있다.

## ACME(DNS-01)·검증 TXT

`txt_records` 변수로 상대 이름(존 기준 `_acme-challenge` 등)과 값 목록을 넣는다. 키는 Terraform용 라벨만 의미 있다.

```hcl
txt_records = {
  acme_api = {
    relative_name = "_acme-challenge.api"
    values        = ["token-from-ca"]
    ttl           = 300
  }
}
```
