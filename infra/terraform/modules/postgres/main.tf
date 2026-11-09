resource "azurerm_private_dns_zone" "this" {
  name                = "${var.name}.private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

locals {
  is_replica = var.create_mode == "Replica"
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = var.postgres_version

  # A read replica inherits credentials from its source; setting them is rejected.
  create_mode            = var.create_mode
  source_server_id       = var.source_server_id
  administrator_login    = local.is_replica ? null : var.administrator_login
  administrator_password = local.is_replica ? null : var.administrator_password

  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.this.id
  public_network_access_enabled = false

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = local.is_replica ? false : var.geo_redundant_backup_enabled

  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode = var.high_availability_mode
    }
  }

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]

  # Azure assigns an availability zone at creation; don't let a re-apply try to
  # change it (flexible server only allows zone changes paired with HA).
  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  count = local.is_replica ? 0 : 1

  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "to-log-analytics"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
