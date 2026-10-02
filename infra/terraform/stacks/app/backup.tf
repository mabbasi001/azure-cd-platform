# Logical database backups (pg_dump) land here daily; the managed PostgreSQL
# server also keeps automated backups (backup_retention_days in the module).
resource "azurerm_storage_account" "backup" {
  name                            = "st${var.product}${var.environment}bak${var.tenant_code}${var.region_code}"
  resource_group_name             = azurerm_resource_group.dev.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

resource "azurerm_storage_container" "backup" {
  name                  = "pg-backups"
  storage_account_name  = azurerm_storage_account.backup.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "backup" {
  storage_account_id = azurerm_storage_account.backup.id

  rule {
    name    = "expire-old-backups"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 30
      }
    }
  }
}
