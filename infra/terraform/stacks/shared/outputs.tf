output "resource_group_name" {
  value = azurerm_resource_group.shared.name
}

output "log_analytics_workspace_id" {
  value = module.monitoring.id
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "acr_id" {
  value = module.acr.id
}

output "key_vault_id" {
  value = module.keyvault.id
}

output "key_vault_uri" {
  value = module.keyvault.uri
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "runner_identity_id" {
  value = azurerm_user_assigned_identity.runner.id
}

output "runner_identity_principal_id" {
  value = azurerm_user_assigned_identity.runner.principal_id
}
