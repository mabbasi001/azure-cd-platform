locals {
  base_app_settings = {
    WEBSITES_PORT                       = tostring(var.container_port)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  appinsights_settings = var.appinsights_connection_string == null ? {} : {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.appinsights_connection_string
  }
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.service_plan_id

  https_only                    = true
  virtual_network_subnet_id     = var.subnet_id
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(local.base_app_settings, local.appinsights_settings, var.app_settings)

  site_config {
    always_on                               = true
    health_check_path                       = var.health_check_path
    health_check_eviction_time_in_min       = 5
    container_registry_use_managed_identity = true
    vnet_route_all_enabled                  = true

    application_stack {
      docker_image_name   = var.image_name
      docker_registry_url = "https://${var.acr_login_server}"
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "to-log-analytics"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
