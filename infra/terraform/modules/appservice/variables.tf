variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "service_plan_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "image_name" {
  description = "Repository and tag, e.g. rw-backend:latest."
  type        = string
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "container_port" {
  type = number
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "subnet_id" {
  description = "Subnet for regional VNet integration."
  type        = string
  default     = null
}

variable "appinsights_connection_string" {
  type      = string
  default   = null
  sensitive = true
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
