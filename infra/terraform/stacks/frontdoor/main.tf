locals {
  prefix = "${var.product}-${var.environment}"

  tags = {
    product   = var.product
    env       = var.environment
    managedBy = "terraform"
  }
}

resource "azurerm_resource_group" "frontdoor" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

module "frontdoor" {
  source              = "../../modules/frontdoor"
  name                = "afd-${local.prefix}"
  endpoint_name       = "${var.product}-${var.environment}-${var.tenant_code}"
  resource_group_name = azurerm_resource_group.frontdoor.name
  sku_name            = var.frontdoor_sku

  backend_origin_hostnames  = var.backend_origin_hostnames
  frontend_origin_hostnames = var.frontend_origin_hostnames

  waf_enabled = var.waf_enabled
  waf_mode    = var.waf_mode

  tags = local.tags
}
