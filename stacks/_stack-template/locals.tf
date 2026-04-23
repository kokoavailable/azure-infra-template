locals {
  # Example naming helper — extend per docs/naming-conventions.md
  example_resource_group_name = "rg-${var.organization}-${var.environment}-${var.region_code}-${var.workload}"

  # Single source for tags: merge into azurerm resources here, or expose via output for remote_state / other stacks.
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
