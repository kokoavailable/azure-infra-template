locals {
  # Example naming helper — extend per docs/naming-conventions.md
  example_resource_group_name = "rg-${var.organization}-${var.environment}-${var.region_code}-${var.workload}"
}
