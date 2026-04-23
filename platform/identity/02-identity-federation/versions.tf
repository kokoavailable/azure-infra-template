terraform {
  required_version = "= 1.14.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.69.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.8.0"
    }
  }
}
