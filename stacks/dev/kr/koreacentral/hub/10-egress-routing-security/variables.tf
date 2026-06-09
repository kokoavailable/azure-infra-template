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
  description = "Short organization or platform prefix used in tags."
}

variable "environment" {
  type        = string
  description = "Execution environment that owns this hub. Use dev, stg, or prod."
  default     = "dev"
}

variable "region_code" {
  type        = string
  description = "Short region code for the Korea Central environment hub."
  default     = "krc"
}

variable "primary_location" {
  type        = string
  description = "Azure region for hub egress resources."
  default     = "koreacentral"
}

variable "egress_resource_group_name" {
  type        = string
  description = "Resource group where environment-hub-owned egress route resources are created."
}

variable "route_tables" {
  type = map(object({
    name                          = string
    disable_bgp_route_propagation = optional(bool, false)
    routes = optional(map(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), {})
  }))
  description = "Approved hub-owned route tables and routes keyed by stable labels. Forced tunnel routes require explicit review."
  default     = {}
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
