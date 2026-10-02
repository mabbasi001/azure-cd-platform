# Observability

Logs and metrics for every tier are centralized in Azure — nothing needs to be read off the
hosts.

## Centralized logging

A single **Log Analytics workspace** (`log-rw-shared`) collects diagnostic logs and metrics from
every tier via `azurerm_monitor_diagnostic_setting` (category group `allLogs` + all metrics):

| Tier | Source | Notable logs |
|------|--------|--------------|
| App | Web Apps (api + web) | `AppServiceConsoleLogs` (container stdout), `AppServiceHTTPLogs` |
| Database | PostgreSQL flexible server | server + query logs, metrics |
| Registry | ACR | repository/image events |
| Secrets | Key Vault | audit events (secret access) |
| Runner | VM | via the Azure Monitor agent (optional) |

Application telemetry (requests, dependencies, exceptions, traces) flows to **Application
Insights** (`appi-rw-dev`), which is workspace-based and therefore also lands in the same Log
Analytics workspace.

### Example queries (Logs / KQL)

```kusto
// Recent container stdout for the API
AppServiceConsoleLogs | where _ResourceId has "api" | order by TimeGenerated desc | take 100

// Slowest API endpoints in the last hour
requests | where timestamp > ago(1h) | summarize p95=percentile(duration,95) by name | order by p95 desc
```

## Historical metrics dashboard

An Application Insights **workbook** ("RealWorld dev - service overview") is deployed as code
(`infra/terraform/stacks/app/observability.tf`) and shows request volume, p95 latency and failure
rate over time — enough to spot and debug bottlenecks. Find it under Application Insights →
Workbooks, or Azure Monitor → Workbooks.
