resource "azurerm_monitor_autoscale_setting" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = var.target_resource_id
  tags                = var.tags

  profile {
    name = "default"

    capacity {
      minimum = var.minimum
      maximum = var.maximum
      default = var.minimum
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.target_resource_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.cpu_scale_out_threshold
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.target_resource_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.cpu_scale_in_threshold
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Backend-style workloads also scale out on a backing-up request queue, which
    # catches saturation that CPU alone misses (e.g. slow downstream calls).
    dynamic "rule" {
      for_each = var.http_queue_scale_out_threshold == null ? [] : [1]
      content {
        metric_trigger {
          metric_name        = "HttpQueueLength"
          metric_resource_id = var.target_resource_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = var.http_queue_scale_out_threshold
        }
        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT5M"
        }
      }
    }
  }
}
