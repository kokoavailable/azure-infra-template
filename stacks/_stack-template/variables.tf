variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for this stack."
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra tenant ID."
}

variable "organization" {
  type        = string
  description = "Organization or platform segment used in default_tags.organization."
}

variable "environment" {
  type        = string
  description = "Lifecycle stage (dev, stg, prod)."
}

variable "workload" {
  type        = string
  description = "Workload or spoke name (for example app-main)."
}

variable "region_code" {
  type        = string
  description = "Short region code (for example krc for koreacentral)."
}

variable "cost_center" {
  type        = string
  description = "Cost allocation tag applied to resources created in this stack."
  default     = "unset"
}

variable "owner" {
  type        = string
  description = "Owning team or group for operational routing."
  default     = "platform"
}
