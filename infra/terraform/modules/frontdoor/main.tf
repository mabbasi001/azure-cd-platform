locals {
  # Origins are ordered by region: the first hostname is the primary (priority 1),
  # the rest are warm standbys (priority 2+). Front Door health probes fail traffic
  # over to the next priority when the primary origin goes unhealthy.
  backend_origins  = { for i, h in var.backend_origin_hostnames : tostring(i) => { host = h, priority = i + 1 } }
  frontend_origins = { for i, h in var.frontend_origin_hostnames : tostring(i) => { host = h, priority = i + 1 } }
}

resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "backend" {
  name                     = "og-api"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = var.backend_health_probe_path
    protocol            = "Https"
    request_type        = "GET"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "frontend" {
  name                     = "og-web"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = var.frontend_health_probe_path
    protocol            = "Https"
    request_type        = "GET"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin" "backend" {
  for_each = local.backend_origins

  name                           = "origin-api-${each.key}"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.backend.id
  enabled                        = true
  host_name                      = each.value.host
  origin_host_header             = each.value.host
  http_port                      = 80
  https_port                     = 443
  priority                       = each.value.priority
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_origin" "frontend" {
  for_each = local.frontend_origins

  name                           = "origin-web-${each.key}"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.frontend.id
  enabled                        = true
  host_name                      = each.value.host
  origin_host_header             = each.value.host
  http_port                      = 80
  https_port                     = 443
  priority                       = each.value.priority
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "backend" {
  name                          = "route-api"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.backend.id
  cdn_frontdoor_origin_ids      = [for o in azurerm_cdn_frontdoor_origin.backend : o.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/api/*", "/docs", "/openapi.json"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = true
}

resource "azurerm_cdn_frontdoor_route" "frontend" {
  name                          = "route-web"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontend.id
  cdn_frontdoor_origin_ids      = [for o in azurerm_cdn_frontdoor_origin.frontend : o.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = true
}

resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
  count = var.waf_enabled ? 1 : 0

  name                = replace("${var.name}waf", "-", "")
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  enabled             = true
  mode                = var.waf_mode
  tags                = var.tags

  # Managed rule sets are a Premium feature; Standard profiles get custom rules only.
  dynamic "managed_rule" {
    for_each = var.sku_name == "Premium_AzureFrontDoor" ? [1] : []
    content {
      type    = "Microsoft_DefaultRuleSet"
      version = "2.1"
      action  = "Block"
    }
  }

  custom_rule {
    name                           = "ratelimit"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = var.rate_limit_threshold
    type                           = "RateLimitRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RequestUri"
      operator           = "Any"
      negation_condition = false
      match_values       = []
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "this" {
  count = var.waf_enabled ? 1 : 0

  name                     = "sp-waf"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this[0].id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
