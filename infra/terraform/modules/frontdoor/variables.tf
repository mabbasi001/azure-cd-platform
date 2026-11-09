variable "name" {
  type = string
}

variable "endpoint_name" {
  description = "Endpoint label; part of the generated *.azurefd.net hostname."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "sku_name" {
  description = "Standard_AzureFrontDoor or Premium_AzureFrontDoor. Managed WAF rules need Premium."
  type        = string
  default     = "Standard_AzureFrontDoor"
}

variable "backend_origin_hostnames" {
  description = "API origin hostnames, primary region first (priority order for failover)."
  type        = list(string)
}

variable "frontend_origin_hostnames" {
  description = "Web origin hostnames, primary region first (priority order for failover)."
  type        = list(string)
}

variable "backend_health_probe_path" {
  type    = string
  default = "/docs"
}

variable "frontend_health_probe_path" {
  type    = string
  default = "/healthz"
}

variable "waf_enabled" {
  type    = bool
  default = true
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}

variable "rate_limit_threshold" {
  description = "Requests per minute per client IP before the WAF rate-limit rule blocks."
  type        = number
  default     = 1000
}

variable "tags" {
  type    = map(string)
  default = {}
}
