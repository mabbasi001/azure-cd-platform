variable "subscription_id" {
  description = "Azure subscription. Leave unset to source from ARM_SUBSCRIPTION_ID; never commit a real id."
  type        = string
  default     = null
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

variable "api_plan_sku" {
  description = "API App Service plan SKU. Autoscale needs Standard (S1) or higher."
  type        = string
  default     = "S1"
}

variable "web_plan_sku" {
  description = "Web App Service plan SKU. Autoscale needs Standard (S1) or higher."
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

variable "postgres_geo_redundant_backup" {
  description = "Store automated backups in the Azure-paired region for cross-region restore."
  type        = bool
  default     = false
}

variable "database_name" {
  type    = string
  default = "conduit"
}

variable "database_role" {
  description = "primary creates a writable server; replica creates a cross-region read replica of replica_source_server_id."
  type        = string
  default     = "primary"

  validation {
    condition     = contains(["primary", "replica"], var.database_role)
    error_message = "database_role must be primary or replica."
  }
}

variable "replica_source_server_id" {
  description = "Primary server to replicate from, when database_role is replica."
  type        = string
  default     = null
}

variable "replica_admin_password" {
  description = "Admin password of the source server, used to build the connection string on a replica deployment."
  type        = string
  default     = null
  sensitive   = true
}

variable "shared_state_key" {
  description = "Remote state key of the shared stack this app tier binds to (per-region for DR)."
  type        = string
  default     = "shared.tfstate"
}

variable "enable_autoscale" {
  type    = bool
  default = true
}

variable "autoscale_min" {
  description = "Minimum instances per plan. Keep >= 2 so no single instance is a SPOF."
  type        = number
  default     = 2
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
