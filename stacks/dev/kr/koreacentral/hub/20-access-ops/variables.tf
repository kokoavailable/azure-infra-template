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
  description = "Short organization or platform prefix used in resource names and tags."
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
  description = "Azure region for hub access operations resources."
  default     = "koreacentral"
}

variable "access_ops_resource_group_name" {
  type        = string
  description = "Resource group where environment-hub-owned access operations resources are created."
}

variable "jumpbox" {
  type = object({
    name                                = string
    subnet_id                           = string
    admin_username                      = string
    admin_ssh_public_key                = string
    vm_size                             = optional(string, "Standard_B1s")
    network_interface_name              = optional(string)
    network_security_group_name         = optional(string)
    public_ip_name                      = optional(string)
    allowed_ssh_source_address_prefixes = optional(list(string), [])
    os_disk_name                        = optional(string)
    os_disk_caching                     = optional(string, "ReadWrite")
    os_disk_storage_account_type        = optional(string, "Standard_LRS")
    custom_data_base64                  = optional(string)
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
      }), {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    })
  })
  description = "Optional custom Linux jumpbox configuration. Leave null until subnet placement, SSH source ranges, and key lifecycle are approved."
  default     = null

  validation {
    condition     = var.jumpbox == null || length(trimspace(var.jumpbox.admin_username)) > 0
    error_message = "jumpbox.admin_username must be set when jumpbox is enabled."
  }

  validation {
    condition     = var.jumpbox == null || length(trimspace(var.jumpbox.admin_ssh_public_key)) > 0
    error_message = "jumpbox.admin_ssh_public_key must be set when jumpbox is enabled."
  }

  validation {
    condition     = var.jumpbox == null || var.jumpbox.public_ip_name == null || length(var.jumpbox.allowed_ssh_source_address_prefixes) > 0
    error_message = "jumpbox.allowed_ssh_source_address_prefixes must contain at least one approved source range when jumpbox.public_ip_name is set."
  }

  validation {
    condition     = var.jumpbox == null || var.jumpbox.custom_data_base64 == null || can(base64decode(var.jumpbox.custom_data_base64))
    error_message = "jumpbox.custom_data_base64 must be valid base64 when set."
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
