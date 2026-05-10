resource "azurerm_resource_group" "hub" {
  name     = local.resource_group_name
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "hub" {
  name                = local.vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "hub" {
  for_each = var.hub_subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value.address_prefixes
}
