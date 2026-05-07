terraform {
  required_version = ">= 1.11.0, < 1.12.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.69.0"
    }
  }
}
