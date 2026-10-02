# Put these into the GitHub repo as Actions secrets/variables:
#   AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID
output "azure_client_id" {
  value = azuread_application.ci.client_id
}

output "azure_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "azure_subscription_id" {
  value = var.subscription_id
}
