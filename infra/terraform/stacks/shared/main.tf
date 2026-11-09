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
  address_space       = [var.address_space]
  tags                = local.tags

  subnets = {
    "snet-${local.prefix}-runner" = {
      address_prefixes = [cidrsubnet(var.address_space, 8, 1)]
    }
    "snet-${local.prefix}-apps" = {
      address_prefixes = [cidrsubnet(var.address_space, 8, 2)]
      delegation = {
        name    = "webapp"
        service = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    "snet-${local.prefix}-db" = {
      address_prefixes = [cidrsubnet(var.address_space, 8, 3)]
      delegation = {
        name    = "postgres"
        service = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    "snet-${local.prefix}-pe" = {
      address_prefixes = [cidrsubnet(var.address_space, 8, 4)]
    }
  }
}

module "acr" {
  source                     = "../../modules/acr"
  name                       = "acr${local.gprefix}${local.suffix}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.shared.name
  sku                        = var.acr_sku
  georeplication_locations   = var.acr_georeplication_locations
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

  # Locked down: default-deny public, reachable via the private endpoint from
  # the VNet and via explicitly allow-listed IPs (CI egress added at run time).
  public_network_access_enabled = true
  network_default_action        = "Deny"
  allowed_ip_rules              = var.admin_ip_rules
}

module "keyvault_pe" {
  source                         = "../../modules/private_endpoint"
  name                           = "pe-${local.prefix}-kv"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.shared.name
  subnet_id                      = module.network.subnet_ids["snet-${local.prefix}-pe"]
  private_connection_resource_id = module.keyvault.id
  subresource_names              = ["vault"]
  private_dns_zone_name          = "privatelink.vaultcore.azure.net"
  vnet_id                        = module.network.vnet_id
  tags                           = local.tags
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
