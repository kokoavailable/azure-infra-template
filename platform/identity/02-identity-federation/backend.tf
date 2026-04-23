# Remote state: the azurerm backend block cannot use variables (Terraform limitation).
# After scripts/bootstrap (or copy backend.hcl.example), keep real values in gitignored
# backend.hcl and run: terraform init -backend-config=backend.hcl
terraform {
  backend "azurerm" {}
}
