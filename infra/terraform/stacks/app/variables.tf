variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "centralus"
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
  default = "cus"
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
  type    = string
  default = "B1"
}

variable "admin_ip_rules" {
  description = "Public IPs/CIDRs allowed through the backup storage firewall."
  type        = list(string)
  default     = []
}
