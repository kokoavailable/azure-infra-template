variable "subscription_id" {
  type        = string
  description = "Target subscription for policy assignments."
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra tenant ID."
}

variable "project_prefix" {
  type        = string
  description = "Short prefix used in policy definition names and assignment names."
  default     = "plt"
}

variable "resource_group_name_pattern" {
  type        = string
  description = "Documented convention for resource groups (see README); not enforced by Azure Policy in this minimal stack."
  default     = "rg-<org>-<env>-<region>-<workload>"
}

variable "assign_require_environment_tag_on_rg" {
  type        = bool
  description = "Assign built-in policy requiring a tag on resource groups (one assignment per key in mandatory_resource_group_tag_keys)."
  default     = true
}

variable "mandatory_resource_group_tag_keys" {
  type        = list(string)
  description = "Tag keys enforced on every resource group; each key gets its own built-in 'Require a tag on resource groups' assignment when assign_require_environment_tag_on_rg is true."
  default     = ["environment"]
}

variable "allowed_azure_regions" {
  type        = list(string)
  description = "Regions allowed for resources (Allowed locations initiative). Empty list disables this assignment."
  default     = ["koreacentral"]
}
