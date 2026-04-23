#!/usr/bin/env bash
# Creates a dedicated storage account + container for Terraform remote state (azurerm backend).
# Idempotent for core resources; run with Azure CLI credentials (user or pipeline with rights).
#
# Config precedence: env file (optional) → script defaults → CLI flags (highest).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap-state-storage.sh [options]

Required:
  --resource-group NAME     Resource group for the storage account (created if missing)
  --location LOCATION       Azure region (e.g. koreacentral)
  --storage-account NAME    Globally unique storage account name (3-24 lowercase alphanum)

Optional:
  --env-file PATH           Load variables from a file (bash KEY=value; see scripts/bootstrap/env/*.env.example)
  --container NAME          Blob container name (default: tfstate)
  --sku SKU                 Storage SKU (default: Standard_GRS)

Environment / env file keys:
  RESOURCE_GROUP, LOCATION, STORAGE_ACCOUNT  Optional when set via env file or inherited env
  CONTAINER_NAME, SKU
  TAG_ENVIRONMENT           Tag value for environment (default: platform)
  TAG_OWNER                 Tag value for owner (default: platform-team)
  TAG_COST_CENTER           Tag value for cost_center (default: infrastructure)

Outputs suggested backend.hcl snippets for stacks.
EOF
}

# Optional --env-file must be applied before defaults + CLI so flags win.
ENV_FILE=""
argv_pre=("$@")
i=0
while [[ $i -lt ${#argv_pre[@]} ]]; do
  case "${argv_pre[$i]}" in
    --env-file)
      if [[ $((i + 1)) -ge ${#argv_pre[@]} ]]; then
        echo "Error: --env-file requires a path." >&2
        exit 1
      fi
      ENV_FILE="${argv_pre[$((i + 1))]}"
      i=$((i + 2))
      ;;
    *)
      i=$((i + 1))
      ;;
  esac
done

if [[ -n "${ENV_FILE}" ]]; then
  if [[ ! -f "${ENV_FILE}" ]]; then
    echo "Error: env file not found: ${ENV_FILE}" >&2
    exit 1
  fi
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-platform-bootstrap-prod}"
LOCATION="${LOCATION:-koreacentral}"
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-stplatformbootstrapprod}"
CONTAINER_NAME="${CONTAINER_NAME:-tfstate}"
SKU="${SKU:-Standard_GRS}"
TAG_ENVIRONMENT="${TAG_ENVIRONMENT:-platform}"
TAG_OWNER="${TAG_OWNER:-platform-team}"
TAG_COST_CENTER="${TAG_COST_CENTER:-infrastructure}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group) RESOURCE_GROUP="$2"; shift 2 ;;
    --location) LOCATION="$2"; shift 2 ;;
    --storage-account) STORAGE_ACCOUNT="$2"; shift 2 ;;
    --env-file) shift 2 ;;
    --container) CONTAINER_NAME="$2"; shift 2 ;;
    --sku) SKU="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "${RESOURCE_GROUP}" || -z "${LOCATION}" || -z "${STORAGE_ACCOUNT}" ]]; then
  echo "Error: --resource-group, --location, and --storage-account are required (CLI or env file)." >&2
  usage
  exit 1
fi

command -v az >/dev/null || {
  echo "Azure CLI (az) is required." >&2
  exit 1
}

echo "==> Ensuring resource group ${RESOURCE_GROUP}"
az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --tags \
    environment="${TAG_ENVIRONMENT}" \
    owner="${TAG_OWNER}" \
    cost_center="${TAG_COST_CENTER}" \
    managed_by=bootstrap-script \
  >/dev/null

echo "==> Ensuring storage account ${STORAGE_ACCOUNT}"
if az storage account show --name "${STORAGE_ACCOUNT}" --resource-group "${RESOURCE_GROUP}" >/dev/null 2>&1; then
  echo "    Storage account already exists; skipping create."
else
  az storage account create \
    --name "${STORAGE_ACCOUNT}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --sku "${SKU}" \
    --kind StorageV2 \
    --allow-blob-public-access false \
    --min-tls-version TLS1_2 \
    --tags \
      environment="${TAG_ENVIRONMENT}" \
      owner="${TAG_OWNER}" \
      cost_center="${TAG_COST_CENTER}" \
      managed_by=bootstrap-script \
    >/dev/null
fi

echo "==> Enabling blob versioning"
az storage account blob-service-properties update \
  --account-name "${STORAGE_ACCOUNT}" \
  --resource-group "${RESOURCE_GROUP}" \
  --enable-versioning true >/dev/null

echo "==> Ensuring container ${CONTAINER_NAME}"
az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --auth-mode login >/dev/null 2>&1 || \
az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --account-key "$(az storage account keys list --resource-group "${RESOURCE_GROUP}" --account-name "${STORAGE_ACCOUNT}" --query '[0].value' -o tsv)" >/dev/null

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
TENANT_ID="$(az account show --query tenantId -o tsv)"

echo ""
echo "=== Bootstrap complete ==="
echo "subscription_id       = ${SUBSCRIPTION_ID}"
echo "tenant_id             = ${TENANT_ID}"
echo "resource_group_name   = ${RESOURCE_GROUP}"
echo "storage_account_name  = ${STORAGE_ACCOUNT}"
echo "container_name        = ${CONTAINER_NAME}"
echo ""
echo "--- backend.hcl fragment (copy per stack; change key per stack path) ---"
cat <<EOF
resource_group_name  = "${RESOURCE_GROUP}"
storage_account_name = "${STORAGE_ACCOUNT}"
container_name       = "${CONTAINER_NAME}"
use_azuread_auth     = true
tenant_id            = "${TENANT_ID}"
subscription_id      = "${SUBSCRIPTION_ID}"
key                  = "<unique-path>.tfstate"
EOF
