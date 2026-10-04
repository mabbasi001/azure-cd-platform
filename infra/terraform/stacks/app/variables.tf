variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "westus3"
}

variable "product" {
  type    = string
  default = "rw"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "tenant_code" {
  type    = string
  default = "e8f"
}

variable "region_code" {
  type    = string
  default = "wus3"
}

variable "postgres_admin_login" {
  type    = string
  default = "rwadmin"
}

variable "backend_image_tag" {
  type    = string
  default = "latest"
}

variable "frontend_image_tag" {
  type    = string
  default = "latest"
}

variable "app_service_sku" {
  description = "App Service plan SKU. Autoscale needs Standard (S1) or higher."
  type        = string
  default     = "S1"
}

variable "postgres_sku" {
  description = "PostgreSQL SKU. HA needs a GP/MO SKU, e.g. GP_Standard_D2s_v3; without HA, B_Standard_B1ms is fine."
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgres_ha_enabled" {
  type    = bool
  default = true
}

variable "enable_autoscale" {
  type    = bool
  default = true
}

variable "autoscale_min" {
  type    = number
  default = 1
}

variable "autoscale_max" {
  type    = number
  default = 3
}

variable "admin_ip_rules" {
  description = "Public IPs/CIDRs allowed through the backup storage firewall."
  type        = list(string)
  default     = []
}
