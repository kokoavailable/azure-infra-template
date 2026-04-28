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
  description = "Short organization or platform prefix (naming)."
}

variable "environment" {
  type        = string
  description = "Tag value for shared platform assets (use shared or platform — not dev/stg/prod)."
  default     = "shared"
}

variable "workload" {
  type        = string
  description = "Workload segment for tagging and RG name (dns-public)."
  default     = "dns-public"
}

variable "region_code" {
  type        = string
  description = "Short region code for the resource group (e.g. krc)."
  default     = "krc"
}

variable "primary_location" {
  type        = string
  description = "Azure region for the DNS zone resource group (DNS itself is global; RG is regional)."
  default     = "koreacentral"
}

variable "root_domain_name" {
  type        = string
  description = "Public DNS apex zone name (the domain you registered, e.g. example.com)."
}

variable "cost_center" {
  type        = string
  description = "Cost allocation tag."
  default     = "unset"
}

variable "owner" {
  type        = string
  description = "Owning team or group tag."
  default     = "platform"
}

variable "txt_records" {
  type = map(object({
    relative_name = string
    values        = list(string)
    ttl           = optional(number, 300)
  }))
  description = "Optional TXT records (ACME DNS-01, domain verification). Keys are stable Terraform labels; relative_name is relative to the zone (e.g. _acme-challenge or _acme-challenge.www)."
  default     = {}
}
