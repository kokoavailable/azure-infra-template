# Baseline policy assignments (built-ins only). RG naming patterns are enforced by convention —
# see README — because subscription-scoped custom definitions vary by provider/API surface.

data "azurerm_policy_definition" "require_tag_on_resource_groups" {
  count        = length(local.tag_keys_for_require_tag_policy) > 0 ? 1 : 0
  display_name = "Require a tag on resource groups"
}

resource "azurerm_subscription_policy_assignment" "require_tag_on_resource_groups" {
  for_each = local.tag_keys_for_require_tag_policy

  name                 = local.assignment_name_require_tag_on_rg[each.key]
  policy_definition_id = data.azurerm_policy_definition.require_tag_on_resource_groups[0].id
  subscription_id      = var.subscription_id
  display_name         = "Require tag ${each.key} on resource groups"

  parameters = jsonencode({
    tagName = {
      value = each.key
    }
  })
}

data "azurerm_policy_definition" "allowed_locations" {
  count        = length(var.allowed_azure_regions) > 0 ? 1 : 0
  display_name = "Allowed locations"
}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  count = length(var.allowed_azure_regions) > 0 ? 1 : 0

  name                 = local.assignment_name_locations
  policy_definition_id = data.azurerm_policy_definition.allowed_locations[0].id
  subscription_id      = var.subscription_id
  display_name         = "Restrict Azure regions"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_azure_regions
    }
  })
}
