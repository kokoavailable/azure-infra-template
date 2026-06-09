resource "azurerm_private_dns_zone" "this" {
  for_each = var.private_dns_zones

  name                = each.value.name
  resource_group_name = var.private_dns_resource_group_name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.virtual_network_links

  name                  = each.value.name
  resource_group_name   = var.private_dns_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_key].name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled

  tags = local.common_tags
}
