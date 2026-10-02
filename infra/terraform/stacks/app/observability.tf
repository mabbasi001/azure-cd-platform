# Historical metrics dashboard (Application Insights workbook): request volume,
# p95 latency and failure rate over time, to spot and debug bottlenecks.
resource "random_uuid" "workbook" {}

resource "azurerm_application_insights_workbook" "overview" {
  name                = random_uuid.workbook.result
  resource_group_name = azurerm_resource_group.dev.name
  location            = var.location
  display_name        = "RealWorld ${var.environment} - service overview"
  source_id           = lower(module.appinsights.id)
  category            = "workbook"
  tags                = local.tags

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type    = 1
        content = { json = "# RealWorld ${var.environment} - service overview\nRequest volume, latency and failures over time." }
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "requests | summarize Requests=count() by bin(timestamp, 15m) | render timechart"
          size         = 0
          title        = "Request volume"
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "requests | summarize p95_ms=percentile(duration, 95) by bin(timestamp, 15m) | render timechart"
          size         = 0
          title        = "p95 latency (ms)"
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "requests | summarize Failures=countif(success == false), Total=count() by bin(timestamp, 15m) | extend FailureRate=todouble(Failures) / Total | render timechart"
          size         = 0
          title        = "Failure rate"
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      }
    ]
    isLocked = false
  })
}
