locals {
  workload                    = "hub-access-ops"
  jumpbox_enabled             = var.jumpbox != null
  jumpbox_public_ip_enabled   = try(var.jumpbox.public_ip_name, null) != null
  jumpbox_ssh_source_prefixes = var.jumpbox == null ? [] : var.jumpbox.allowed_ssh_source_address_prefixes

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
