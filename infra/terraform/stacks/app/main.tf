data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-rw-shared-tfstate"
    storage_account_name = "strwsharedtfstatee8fwus3"
    container_name       = "tfstate"
    key                  = var.shared_state_key
    use_azuread_auth     = true
  }
}

locals {
  prefix  = "${var.product}-${var.environment}"
  gprefix = "${var.product}${var.environment}"
  suffix  = "${var.tenant_code}${var.region_code}"

  shared = data.terraform_remote_state.shared.outputs

  # A replica deployment (secondary region) reads from a cross-region replica of the
  # primary server; it shares the source's admin password, supplied out of band.
  is_db_replica = var.database_role == "replica"
  db_password   = local.is_db_replica ? var.replica_admin_password : random_password.postgres.result

  tags = {
    product   = var.product
    env       = var.environment
    managedBy = "terraform"
  }
}

resource "azurerm_resource_group" "dev" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

resource "random_password" "postgres" {
  length  = 32
  special = false
}

resource "random_password" "app_secret_key" {
  length  = 50
  special = false
}

module "appinsights" {
  source                     = "../../modules/appinsights"
  name                       = "appi-${local.prefix}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.dev.name
  log_analytics_workspace_id = local.shared.log_analytics_workspace_id
  tags                       = local.tags
}

module "postgres" {
  source                       = "../../modules/postgres"
  name                         = "psql-${local.prefix}-${var.tenant_code}-${var.region_code}"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.dev.name
  administrator_login          = var.postgres_admin_login
  administrator_password       = random_password.postgres.result
  database_name                = var.database_name
  sku_name                     = var.postgres_sku
  high_availability_enabled    = local.is_db_replica ? false : var.postgres_ha_enabled
  geo_redundant_backup_enabled = var.postgres_geo_redundant_backup
  create_mode                  = local.is_db_replica ? "Replica" : "Default"
  source_server_id             = local.is_db_replica ? var.replica_source_server_id : null
  delegated_subnet_id          = local.shared.subnet_ids["snet-rw-shared-db"]
  vnet_id                      = local.shared.vnet_id
  log_analytics_workspace_id   = local.shared.log_analytics_workspace_id
  tags                         = local.tags
}

resource "azurerm_key_vault_secret" "app_secret_key" {
  name         = "app-secret-key"
  value        = random_password.app_secret_key.result
  key_vault_id = local.shared.key_vault_id
  tags         = local.tags
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "database-url"
  value        = "postgresql://${var.postgres_admin_login}:${local.db_password}@${module.postgres.fqdn}:5432/${var.database_name}?sslmode=require"
  key_vault_id = local.shared.key_vault_id
  tags         = local.tags
}

# Separate plans so the API and web tiers scale independently on their own signals.
resource "azurerm_service_plan" "api" {
  name                = "plan-${local.prefix}-api"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  os_type             = "Linux"
  sku_name            = var.api_plan_sku
  tags                = local.tags
}

resource "azurerm_service_plan" "web" {
  name                = "plan-${local.prefix}-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  os_type             = "Linux"
  sku_name            = var.web_plan_sku
  tags                = local.tags
}

module "autoscale_api" {
  source   = "../../modules/autoscale"
  count    = var.enable_autoscale ? 1 : 0
  name     = "autoscale-${local.prefix}-api"
  location = var.location

  resource_group_name            = azurerm_resource_group.dev.name
  target_resource_id             = azurerm_service_plan.api.id
  minimum                        = var.autoscale_min
  maximum                        = var.autoscale_max
  http_queue_scale_out_threshold = 25
  tags                           = local.tags
}

module "autoscale_web" {
  source   = "../../modules/autoscale"
  count    = var.enable_autoscale ? 1 : 0
  name     = "autoscale-${local.prefix}-web"
  location = var.location

  resource_group_name = azurerm_resource_group.dev.name
  target_resource_id  = azurerm_service_plan.web.id
  minimum             = var.autoscale_min
  maximum             = var.autoscale_max
  tags                = local.tags
}

module "backend" {
  source              = "../../modules/appservice"
  name                = "app-${local.prefix}-api-${var.tenant_code}-${var.region_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  service_plan_id     = azurerm_service_plan.api.id
  acr_login_server    = local.shared.acr_login_server
  image_name          = "rw-backend:${var.backend_image_tag}"
  container_port      = 8000
  health_check_path   = "/docs"
  subnet_id           = local.shared.subnet_ids["snet-rw-shared-apps"]

  appinsights_connection_string = module.appinsights.connection_string
  log_analytics_workspace_id    = local.shared.log_analytics_workspace_id

  app_settings = {
    APP_ENV       = "prod"
    DEBUG         = "false"
    ALLOWED_HOSTS = jsonencode(["*"])
    SECRET_KEY    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.app_secret_key.versionless_id})"
    DATABASE_URL  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_url.versionless_id})"
  }

  tags = local.tags
}

module "frontend" {
  source              = "../../modules/appservice"
  name                = "app-${local.prefix}-web-${var.tenant_code}-${var.region_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  service_plan_id     = azurerm_service_plan.web.id
  acr_login_server    = local.shared.acr_login_server
  image_name          = "rw-frontend:${var.frontend_image_tag}"
  container_port      = 80
  health_check_path   = "/healthz"
  subnet_id           = local.shared.subnet_ids["snet-rw-shared-apps"]

  log_analytics_workspace_id = local.shared.log_analytics_workspace_id

  app_settings = {
    API_URL = "https://${module.backend.default_hostname}/api"
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "backend_acr_pull" {
  scope                = local.shared.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.backend.principal_id
}

resource "azurerm_role_assignment" "frontend_acr_pull" {
  scope                = local.shared.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.frontend.principal_id
}

resource "azurerm_role_assignment" "backend_kv_secrets" {
  scope                = local.shared.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.backend.principal_id
}
