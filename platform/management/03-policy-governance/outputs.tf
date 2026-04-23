output "policy_assignment_allowed_locations_id" {
  description = "Resource ID of the Allowed locations assignment (null if disabled)."
  value       = try(azurerm_subscription_policy_assignment.allowed_locations[0].id, null)
}

output "policy_assignment_require_tag_on_rg_id" {
  description = "Resource ID of the Require a tag on resource groups assignment."
  value       = try(azurerm_subscription_policy_assignment.require_environment_tag_on_resource_groups[0].id, null)
}

output "documented_resource_group_name_pattern" {
  description = "Human-readable RG naming convention referenced by modules/stacks (policy enforcement optional)."
  value       = var.resource_group_name_pattern
}
