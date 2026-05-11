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
  description = "Short organization or platform prefix used in resource names."
}

variable "environment" {
  type        = string
  description = "Execution environment that owns this hub. Use dev, stg, or prod."
  default     = "dev"
}

variable "workload" {
  type        = string
  description = "Workload segment for naming and tagging."
  default     = "hub-network"
}

variable "region_code" {
  type        = string
  description = "Short region code for the Korea Central environment hub."
  default     = "krc"
}

variable "primary_location" {
  type        = string
  description = "Azure region for the hub network resources."
  default     = "koreacentral"
}

variable "hub_address_space" {
  type        = list(string)
  description = "Address spaces for the Korea Central hub virtual network. CIDR allocation requires human approval before plan/apply."
}

variable "hub_subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "Hub subnet definitions keyed by stable labels. Subnet layout requires human approval before plan/apply."
}

variable "cost_center" {
  type        = string
  description = "Cost allocation tag."
  default     = "unset"
}

variable "owner" {
  type        = string
  description = "Owning team or group tag."
  default     = "network"
}
