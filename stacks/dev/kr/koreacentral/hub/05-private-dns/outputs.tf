output "private_dns_zone_ids" {
  description = "Private DNS zone resource IDs keyed by stable zone labels."
  value = {
    for key, zone in azurerm_private_dns_zone.this : key => zone.id
  }
}

output "private_dns_zone_names" {
  description = "Private DNS zone names keyed by stable zone labels."
  value = {
    for key, zone in azurerm_private_dns_zone.this : key => zone.name
  }
}

output "virtual_network_link_ids" {
  description = "Private DNS VNet link resource IDs keyed by stable link labels."
  value = {
    for key, link in azurerm_private_dns_zone_virtual_network_link.this : key => link.id
  }
}
