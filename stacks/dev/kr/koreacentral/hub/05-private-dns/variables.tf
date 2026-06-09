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

variable "private_dns_resource_group_name" {
  type        = string
  description = "Resource group where environment-hub-owned private DNS zones are created."
}

variable "private_dns_zones" {
  type = map(object({
    name = string
  }))
  description = "Approved environment-owned Azure Private DNS zones keyed by stable labels."
  default     = {}
}

variable "virtual_network_links" {
  type = map(object({
    zone_key             = string
    name                 = string
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
  }))
  description = "Approved VNet links for centralized private DNS zones. Spoke links require explicit inputs."
  default     = {}

  validation {
    condition = alltrue([
      for link in var.virtual_network_links : contains(keys(var.private_dns_zones), link.zone_key)
    ])
    error_message = "Each virtual_network_links entry must reference an existing private_dns_zones key."
  }
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
