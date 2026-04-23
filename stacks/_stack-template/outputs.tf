output "example_resource_group_name" {
  description = "Example RG name derived from naming convention locals."
  value       = local.example_resource_group_name
}

output "common_tags" {
  description = "Standard tag map for this stack; consume via terraform_remote_state or pass into modules as tags = merge(local.common_tags, ...)."
  value       = local.common_tags
}
