output "resource_group_name" {
  value = azurerm_resource_group.dev.name
}

output "backend_url" {
  value = "https://${module.backend.default_hostname}"
}

output "frontend_url" {
  value = "https://${module.frontend.default_hostname}"
}

output "backend_app_name" {
  value = module.backend.name
}

output "frontend_app_name" {
  value = module.frontend.name
}

output "postgres_fqdn" {
  value = module.postgres.fqdn
}

output "backup_storage_account" {
  value = azurerm_storage_account.backup.name
}

output "backup_container" {
  value = azurerm_storage_container.backup.name
}
