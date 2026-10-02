# Resource Naming Convention

All Azure resources follow a predictable scheme so that ownership, environment, and
purpose are readable from the name alone.

## Pattern

Dash-friendly resources:

```
<type>-<product>-<env>[-<descriptor>]
```

Globally-unique resources that disallow dashes (storage accounts, container
registries) append a tenant code and region and drop the separators:

```
<type><product><env><descriptor><tenant><region>
```

## Segments

| Segment | Value(s) | Notes |
|---------|----------|-------|
| product | `rw` | RealWorld CD platform |
| env | `shared`, `dev`, `prod` | `shared` = cross-environment infra (state, ACR, runner) |
| tenant | `e8f` | uniqueness code for globally-unique names, derived deterministically from the Azure tenant GUID: `sha256(tenantId)[0:3]` |
| region | `neu` | North Europe. (West Europe `weu` was the first choice but the subscription is capacity-blocked there.) |

## Type prefixes

| Resource | Prefix | Example |
|----------|--------|---------|
| Resource group | `rg-` | `rg-rw-dev` |
| Storage account | `st` | `strwdevbake8fneu` |
| Container registry | `acr` | `acrrwsharede8fneu` |
| Key Vault | `kv-` | `kv-rw-dev-e8f-neu` |
| PostgreSQL server | `psql-` | `psql-rw-dev-e8f-neu` |
| App Service plan | `plan-` | `plan-rw-dev` |
| Web App | `app-` | `app-rw-dev-api-e8f-neu`, `app-rw-dev-web-e8f-neu` |
| Log Analytics workspace | `log-` | `log-rw-shared` |
| Application Insights | `appi-` | `appi-rw-dev` |
| Virtual network | `vnet-` | `vnet-rw-dev` |
| Subnet | `snet-` | `snet-rw-dev-apps` |
| Managed identity | `id-` | `id-rw-dev-app` |
| Virtual machine | `vm-` | `vm-rw-shared-runner` |
| Network interface | `nic-` | `nic-rw-shared-runner` |
| Network security group | `nsg-` | `nsg-rw-shared-runner` |
| Public IP | `pip-` | `pip-rw-shared-runner` |

## Tags

Every resource carries: `product=rw`, `env=<env>`, `managedBy=terraform` (or
`manual` for bootstrap resources), and `purpose=<short>`.

## Bootstrap (manually created) resources

| Resource | Name |
|----------|------|
| State resource group | `rg-rw-shared-tfstate` |
| State storage account | `strwsharedtfstatee8fneu` |
| State container | `tfstate` |
