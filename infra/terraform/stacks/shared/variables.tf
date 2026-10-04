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
  default = "shared"
}

variable "tenant_code" {
  description = "Uniqueness code for globally-unique resource names (sha256(tenantId)[0:3])."
  type        = string
  default     = "e8f"
}

variable "region_code" {
  type    = string
  default = "cus"
}

variable "admin_ip_rules" {
  description = "Public IPs/CIDRs allowed through the Key Vault firewall (admin/bootstrap access)."
  type        = list(string)
  default     = []
}
