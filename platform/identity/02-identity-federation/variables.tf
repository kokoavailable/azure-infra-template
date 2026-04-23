variable "subscription_id" {
  type        = string
  description = "Azure subscription ID where RBAC assignments are applied."
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra tenant ID."
}

variable "project_prefix" {
  type        = string
  description = "Short prefix for Azure AD application display name and related resources."
  default     = "gha-iac"
}

variable "github_organization" {
  type        = string
  description = "GitHub organization or user that owns the repository."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name without org (e.g. azure-infra-template)."
}

variable "default_branch" {
  type        = string
  description = "Branch used for GitHub Actions OIDC subject (refs/heads/<branch>)."
  default     = "main"
}

variable "additional_github_branches" {
  type        = list(string)
  description = "Extra branch names (without refs/heads/) that should receive federated credentials."
  default     = []
}

variable "terraform_state_resource_group_name" {
  type        = string
  description = "Resource group containing the Terraform remote state storage account."
  default     = ""
}

variable "terraform_state_storage_account_name" {
  type        = string
  description = "Storage account hosting tfstate blobs. When set with RG, CI principal receives Storage Blob Data Contributor."
  default     = ""
}

variable "subscription_role_name" {
  type        = string
  description = "RBAC role at subscription scope for the CI service principal."
  default     = "Contributor"
}

variable "enable_subscription_role_assignment" {
  type        = bool
  description = "Assign subscription_role_name to the GitHub Actions service principal."
  default     = true
}
