# Terraform

Infrastructure as code for the platform, split into reusable `modules/` and per-environment
stacks under `stacks/`.

```
modules/
  monitoring/      Log Analytics workspace
  network/         VNet + subnets (optional delegation / service endpoints)
  acr/             Azure Container Registry (+ optional geo-replication) + diagnostics
  keyvault/        Key Vault (RBAC auth) + diagnostics
  postgres/        VNet-integrated PostgreSQL flexible server + private DNS;
                   geo-redundant backup + cross-region read-replica mode
  appinsights/     Application Insights (workspace-based)
  appservice/      Linux Web App for Containers (MI ACR pull, VNet integration)
  autoscale/       App Service plan autoscale (CPU + optional HTTP queue length)
  frontdoor/       Azure Front Door (global LB + WAF + TLS + health failover)
  private_endpoint/ generic private endpoint + private DNS zone + link
stacks/
  identity/     GitHub OIDC app registration + federated creds + RBAC (bootstrap)
  shared/       cross-environment infra: RG, Log Analytics, ACR, Key Vault,
                VNet, runner identity, RBAC
  app/          application tier (Postgres, App Insights, per-app plans + autoscale,
                web apps, KV secrets); one stack, per-environment and per-region
                via Terraform workspaces + *.tfvars
  frontdoor/    global entry point; origins point at each region's app tier
```

`shared` and `identity` are distinct one-off stacks. The `app` stack is
environment-agnostic: `dev`/`staging`/`prod` are **workspaces** with their own
`*.tfvars`, not copied folders (see `stacks/app/README.md`).

Apply order: `identity` and `shared` first (any order), then `app`
(reads `shared` remote state).

The self-hosted CI runner (its Terraform + Ansible) lives separately in
`runner-infra/` at the repo root, since it is shared CI/platform infrastructure
rather than part of the application delivery.

## State

Remote state lives in the bootstrap storage account (created manually, see
`docs/conventions/naming.md`): `rg-rw-shared-tfstate` / `strwsharedtfstatee8fwus3`, container
`tfstate`, one key per environment (`shared.tfstate`, ...). The backend uses Azure AD auth, so
no storage keys are needed — the caller must hold **Storage Blob Data Contributor** on the
state account.

## Usage

From an environment directory (e.g. `stacks/shared`):

```
export ARM_USE_AZUREAD=true
terraform init
terraform plan
terraform apply
```

Authentication is via the Azure CLI (`az login`) locally, or GitHub OIDC in CI.
