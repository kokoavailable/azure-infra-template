output "azure_application_client_id" {
  description = "App (client) ID — set GitHub secret AZURE_CLIENT_ID to this value."
  value       = azuread_application.github_oidc.client_id
}

output "azure_tenant_id" {
  description = "Tenant ID (same as var.tenant_id). Set AZURE_TENANT_ID."
  value       = var.tenant_id
}

output "azure_subscription_id" {
  description = "Subscription ID used for RBAC scope."
  value       = var.subscription_id
}

output "github_oidc_subject_example" {
  description = "Example federated credential subject for the default branch."
  value       = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${var.default_branch}"
}
