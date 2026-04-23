#!/usr/bin/env bash
# Deletes the bootstrap resource group (Terraform remote state storage and everything in that RG).
# Same env-file / CLI variable names as bootstrap-state-storage.sh; only RESOURCE_GROUP is used for delete.
#
# Config precedence: env file (optional) → script defaults → CLI flags (highest).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap-state-teardown.sh --yes [options]

  Deletes the entire resource group (az group delete). All Terraform state in that
  storage account will be destroyed. Irreversible.

Required:
  --yes                     Confirm destruction (mandatory)

  --resource-group NAME   Resource group to delete (or set RESOURCE_GROUP via env file)

Optional:
  --env-file PATH           Same as bootstrap-state-storage.sh (see scripts/bootstrap/env/*.env.example)

Without --resource-group / env file, script defaults apply (same as bootstrap); you almost
always want --env-file or explicit --resource-group matching the bootstrap you ran.
EOF
}

YES="false"
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) YES="true"; shift ;;
    --resource-group) RESOURCE_GROUP="$2"; shift 2 ;;
    --env-file) shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "${YES}" != "true" ]]; then
  echo "Error: refusing to delete without --yes." >&2
  usage
  exit 1
fi

if [[ -z "${RESOURCE_GROUP}" ]]; then
  echo "Error: RESOURCE_GROUP is empty (use --resource-group or env file)." >&2
  exit 1
fi

command -v az >/dev/null || {
  echo "Azure CLI (az) is required." >&2
  exit 1
}

if ! az group show --name "${RESOURCE_GROUP}" >/dev/null 2>&1; then
  echo "==> Resource group not found (nothing to delete): ${RESOURCE_GROUP}"
  exit 0
fi

echo "==> Deleting resource group: ${RESOURCE_GROUP}"
az group delete --name "${RESOURCE_GROUP}" --yes --no-wait

echo ""
echo "=== Teardown started ==="
echo "Delete is asynchronous (--no-wait). Check portal or: az group show -n ${RESOURCE_GROUP}"
echo "When the group is gone, remote Terraform state for stacks using this backend is gone."
