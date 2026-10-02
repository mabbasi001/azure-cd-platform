# Terraform

Infrastructure as code for the platform, split into reusable `modules/` and per-environment
stacks under `envs/`.

```
modules/
  monitoring/   Log Analytics workspace
  network/      VNet + subnets (optional delegation / service endpoints)
  acr/          Azure Container Registry + diagnostics
  keyvault/     Key Vault (RBAC auth) + diagnostics
envs/
  shared/       cross-environment infra: RG, Log Analytics, ACR, Key Vault,
                VNet, runner identity, RBAC
```

## State

Remote state lives in the bootstrap storage account (created manually, see
`docs/conventions/naming.md`): `rg-rw-shared-tfstate` / `strwsharedtfstatee8fneu`, container
`tfstate`, one key per environment (`shared.tfstate`, ...). The backend uses Azure AD auth, so
no storage keys are needed — the caller must hold **Storage Blob Data Contributor** on the
state account.

## Usage

From an environment directory (e.g. `envs/shared`):

```
export ARM_USE_AZUREAD=true
terraform init
terraform plan
terraform apply
```

Authentication is via the Azure CLI (`az login`) locally, or GitHub OIDC in CI.
