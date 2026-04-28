output "dns_zone_id" {
  description = "Resource ID of the public DNS zone."
  value       = azurerm_dns_zone.public.id
}

output "dns_zone_name" {
  description = "Public zone name (apex)."
  value       = azurerm_dns_zone.public.name
}

output "name_servers" {
  description = "Azure-assigned name servers — create the same NS delegation at your domain registrar."
  value       = azurerm_dns_zone.public.name_servers
}

output "resource_group_name" {
  description = "Resource group hosting the zone."
  value       = azurerm_resource_group.dns.name
}

output "fqdn_environment_roots" {
  description = "Agreed environment hostnames (dev/stg/prod first label under the apex). Add CNAME/A/ALIAS at edge stacks as needed."
  value       = local.fqdn_environment_roots
}
