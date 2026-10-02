data "azurerm_client_config" "current" {}

locals {
  prefix  = "${var.product}-${var.environment}"
  gprefix = "${var.product}${var.environment}"
  suffix  = "${var.tenant_code}${var.region_code}"

  tags = {
    product   = var.product
    env       = var.environment
    managedBy = "terraform"
  }
}

resource "azurerm_resource_group" "shared" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  name                = "log-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  tags                = local.tags
}

module "network" {
  source              = "../../modules/network"
  name                = "vnet-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  address_space       = ["10.10.0.0/16"]
  tags                = local.tags

  subnets = {
    "snet-${local.prefix}-runner" = {
      address_prefixes = ["10.10.1.0/24"]
    }
    "snet-${local.prefix}-apps" = {
      address_prefixes = ["10.10.2.0/24"]
      delegation = {
        name    = "webapp"
        service = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    "snet-${local.prefix}-db" = {
      address_prefixes = ["10.10.3.0/24"]
      delegation = {
        name    = "postgres"
        service = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    "snet-${local.prefix}-pe" = {
      address_prefixes = ["10.10.4.0/24"]
    }
  }
}

module "acr" {
  source                     = "../../modules/acr"
  name                       = "acr${local.gprefix}${local.suffix}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.shared.name
  sku                        = "Basic"
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "keyvault" {
  source                     = "../../modules/keyvault"
  name                       = "kv-${local.prefix}-${var.tenant_code}-${var.region_code}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.shared.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

resource "azurerm_user_assigned_identity" "runner" {
  name                = "id-${local.prefix}-runner"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "runner_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.runner.principal_id
}

resource "azurerm_role_assignment" "deployer_kv_secrets" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
