resource "azurerm_resource_group" "dns" {
  name     = local.resource_group_name
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_dns_zone" "public" {
  name                = var.root_domain_name
  resource_group_name = azurerm_resource_group.dns.name

  tags = local.common_tags
}

resource "azurerm_dns_txt_record" "optional" {
  for_each = var.txt_records

  name                = each.value.relative_name
  resource_group_name = azurerm_resource_group.dns.name
  zone_name           = azurerm_dns_zone.public.name
  ttl                 = each.value.ttl

  dynamic "record" {
    for_each = each.value.values
    content {
      value = record.value
    }
  }
}
