data "azurerm_subscription" "current" {}

data "azurerm_storage_account" "tfstate" {
  count               = var.terraform_state_storage_account_name != "" && var.terraform_state_resource_group_name != "" ? 1 : 0
  name                = var.terraform_state_storage_account_name
  resource_group_name = var.terraform_state_resource_group_name
}

locals {
  github_repo_full = "${var.github_organization}/${var.github_repository}"

  federated_branch_names = distinct(concat(
    [var.default_branch],
    var.additional_github_branches
  ))

  federated_credentials = {
    for b in local.federated_branch_names : b => {
      display_name = "github-${replace(b, "/", "-")}"
      subject      = "repo:${local.github_repo_full}:ref:refs/heads/${b}"
    }
  }
}

resource "azuread_application" "github_oidc" {
  display_name = "${var.project_prefix}-${var.github_repository}-ci"
}

resource "azuread_service_principal" "github_oidc" {
  client_id = azuread_application.github_oidc.client_id
}

resource "azuread_application_federated_identity_credential" "github_branch" {
  for_each = local.federated_credentials

  application_id = azuread_application.github_oidc.id
  display_name   = each.value.display_name
  description    = "GitHub Actions OIDC for branch ${each.key}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = each.value.subject
}

resource "azurerm_role_assignment" "subscription_ci" {
  count = var.enable_subscription_role_assignment ? 1 : 0

  scope                = data.azurerm_subscription.current.id
  role_definition_name = var.subscription_role_name
  principal_id         = azuread_service_principal.github_oidc.object_id
}

resource "azurerm_role_assignment" "tfstate_blob_data" {
  count = length(data.azurerm_storage_account.tfstate) > 0 ? 1 : 0

  scope                = data.azurerm_storage_account.tfstate[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github_oidc.object_id
}
