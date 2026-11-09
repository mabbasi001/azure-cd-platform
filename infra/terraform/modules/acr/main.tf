resource "azurerm_container_registry" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  admin_enabled       = false
  tags                = var.tags

  # Geo-replication needs Premium; each region pulls images from a local replica.
  dynamic "georeplications" {
    for_each = toset(var.georeplication_locations)
    content {
      location = georeplications.value
      tags     = var.tags
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "to-log-analytics"
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
