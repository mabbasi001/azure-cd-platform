terraform {
  backend "azurerm" {
    resource_group_name  = "rg-rw-shared-tfstate"
    storage_account_name = "strwsharedtfstatee8fwus3"
    container_name       = "tfstate"
    key                  = "app.tfstate"
    use_azuread_auth     = true
  }
}
