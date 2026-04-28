locals {
  resource_group_name = "rg-${var.organization}-${var.environment}-${var.region_code}-${var.workload}"

  common_tags = {
    organization = var.organization
    environment  = var.environment
    workload     = var.workload
    region_code  = var.region_code
    owner        = var.owner
    cost_center  = var.cost_center
    managed_by   = "iac"
  }

  # Convention: one environment slice per subdomain under the apex (document for edge/apps later).
  fqdn_environment_roots = {
    dev  = "dev.${var.root_domain_name}"
    stg  = "stg.${var.root_domain_name}"
    prod = "prod.${var.root_domain_name}"
  }
}
