variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "postgres_version" {
  type    = string
  default = "15"
}

variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "storage_mb" {
  type    = number
  default = 32768
}

variable "administrator_login" {
  type = string
}

variable "administrator_password" {
  type      = string
  sensitive = true
}

variable "database_name" {
  type    = string
  default = "conduit"
}

variable "delegated_subnet_id" {
  type = string
}

variable "vnet_id" {
  description = "VNet to link the private DNS zone to."
  type        = string
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "enable_diagnostics" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
