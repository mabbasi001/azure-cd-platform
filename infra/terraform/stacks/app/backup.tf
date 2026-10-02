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

  # Locked down: reachable via the private endpoint from the VNet and via
  # explicitly allow-listed IPs (CI egress added at run time).
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = var.admin_ip_rules
  }

  # CI adds/removes its ephemeral egress IP imperatively per run.
  lifecycle {
    ignore_changes = [network_rules[0].ip_rules]
  }
}

module "backup_pe" {
  source                         = "../../modules/private_endpoint"
  name                           = "pe-${local.prefix}-bak"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.dev.name
  subnet_id                      = local.shared.subnet_ids["snet-rw-shared-pe"]
  private_connection_resource_id = azurerm_storage_account.backup.id
  subresource_names              = ["blob"]
  private_dns_zone_name          = "privatelink.blob.core.windows.net"
  vnet_id                        = local.shared.vnet_id
  tags                           = local.tags
}

# The container is created by the backup workflow after it allow-lists its
# egress IP, to avoid a data-plane create against the default-deny account.

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
