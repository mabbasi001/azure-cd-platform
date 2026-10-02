variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "enable_diagnostics" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "network_default_action" {
  description = "Default network ACL action: Deny locks the vault down (PE + explicit allow only)."
  type        = string
  default     = "Allow"
}

variable "allowed_ip_rules" {
  description = "Public IPs/CIDRs allowed through the firewall (e.g. CI egress)."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
