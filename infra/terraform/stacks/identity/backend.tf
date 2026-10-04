terraform {
  backend "azurerm" {
    resource_group_name  = "rg-rw-shared-tfstate"
    storage_account_name = "strwsharedtfstatee8fcus"
    container_name       = "tfstate"
    key                  = "identity.tfstate"
    use_azuread_auth     = true
  }
}
