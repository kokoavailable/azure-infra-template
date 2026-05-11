locals {
  resource_group_name = "rg-${var.organization}-${var.environment}-${var.region_code}-${var.workload}"
  vnet_name           = "vnet-${var.organization}-${var.environment}-${var.region_code}-hub"

  common_tags = {
    organization = var.organization
    environment  = var.environment
    workload     = var.workload
    region_code  = var.region_code
    owner        = var.owner
    cost_center  = var.cost_center
    managed_by   = "iac"
  }
}
