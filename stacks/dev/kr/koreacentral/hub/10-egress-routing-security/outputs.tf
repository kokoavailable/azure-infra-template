output "route_table_ids" {
  description = "Hub egress route table resource IDs keyed by stable route table labels."
  value = {
    for key, table in azurerm_route_table.this : key => table.id
  }
}

output "route_table_names" {
  description = "Hub egress route table names keyed by stable route table labels."
  value = {
    for key, table in azurerm_route_table.this : key => table.name
  }
}
