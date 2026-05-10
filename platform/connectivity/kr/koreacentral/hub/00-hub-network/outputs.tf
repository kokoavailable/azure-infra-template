output "resource_group_name" {
  description = "Resource group that owns the Korea Central hub virtual network."
  value       = azurerm_resource_group.hub.name
}

output "hub_vnet_id" {
  description = "Resource ID of the Korea Central hub virtual network."
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the Korea Central hub virtual network."
  value       = azurerm_virtual_network.hub.name
}

output "hub_vnet_address_space" {
  description = "Configured address spaces for the Korea Central hub virtual network."
  value       = azurerm_virtual_network.hub.address_space
}

output "hub_subnet_ids" {
  description = "Hub subnet resource IDs keyed by stable subnet labels."
  value = {
    for key, subnet in azurerm_subnet.hub : key => subnet.id
  }
}

output "hub_subnet_names" {
  description = "Hub subnet names keyed by stable subnet labels."
  value = {
    for key, subnet in azurerm_subnet.hub : key => subnet.name
  }
}
