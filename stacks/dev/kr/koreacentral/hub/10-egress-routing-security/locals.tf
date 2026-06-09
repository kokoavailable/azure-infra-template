locals {
  workload = "hub-egress"

  common_tags = {
    organization = var.organization
    environment  = var.environment
    workload     = local.workload
    region_code  = var.region_code
    owner        = var.owner
    cost_center  = var.cost_center
    managed_by   = "iac"
  }
}
