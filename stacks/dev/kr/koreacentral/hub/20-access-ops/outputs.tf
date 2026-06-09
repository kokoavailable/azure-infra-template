output "jumpbox_virtual_machine_id" {
  description = "Custom jumpbox virtual machine resource ID when jumpbox is enabled."
  value       = try(azurerm_linux_virtual_machine.jumpbox["this"].id, null)
}

output "jumpbox_network_interface_id" {
  description = "Custom jumpbox network interface resource ID when jumpbox is enabled."
  value       = try(azurerm_network_interface.jumpbox["this"].id, null)
}

output "jumpbox_network_security_group_id" {
  description = "Custom jumpbox network security group resource ID when jumpbox is enabled."
  value       = try(azurerm_network_security_group.jumpbox["this"].id, null)
}

output "jumpbox_private_ip_address" {
  description = "Custom jumpbox private IP address when jumpbox is enabled."
  value       = try(azurerm_network_interface.jumpbox["this"].private_ip_address, null)
}

output "jumpbox_public_ip_address" {
  description = "Custom jumpbox public IP address when public IP access is enabled."
  value       = try(azurerm_public_ip.jumpbox["this"].ip_address, null)
}
