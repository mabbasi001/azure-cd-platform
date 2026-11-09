variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "Basic"
}

variable "georeplication_locations" {
  description = "Regions to geo-replicate the registry to. Requires the Premium SKU. Empty = single region."
  type        = list(string)
  default     = []
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
