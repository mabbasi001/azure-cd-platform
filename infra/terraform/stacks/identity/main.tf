data "azuread_client_config" "current" {}

resource "azuread_application" "ci" {
  display_name = var.application_display_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "ci" {
  client_id = azuread_application.ci.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_federated_identity_credential" "github" {
  for_each = var.federated_subjects

  application_id = azuread_application.ci.id
  display_name   = "github-${each.key}"
  description    = "GitHub Actions OIDC (${each.key})"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = each.value
}

# The CI identity runs Terraform (create infra), creates role assignments
# (AcrPull/Key Vault roles in the app stack), and pushes images to ACR.
locals {
  subscription_scope = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_role_assignment" "ci_contributor" {
  scope                = local.subscription_scope
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.ci.object_id
}

resource "azurerm_role_assignment" "ci_user_access_admin" {
  scope                = local.subscription_scope
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.ci.object_id
}

resource "azurerm_role_assignment" "ci_acr_push" {
  scope                = local.subscription_scope
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.ci.object_id
}
