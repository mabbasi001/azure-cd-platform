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
  default = "shared"
}

variable "tenant_code" {
  description = "Uniqueness code for globally-unique resource names (sha256(tenantId)[0:3])."
  type        = string
  default     = "e8f"
}

variable "region_code" {
  type    = string
  default = "wus3"
}

variable "admin_ip_rules" {
  description = "Public IPs/CIDRs allowed through the Key Vault firewall (admin/bootstrap access)."
  type        = list(string)
  default     = []
}

variable "budget_amount" {
  description = "Monthly subscription budget in the billing currency."
  type        = number
  default     = 150
}

variable "budget_contact_emails" {
  type    = list(string)
  default = ["mabbasi_@outlook.com"]
}

variable "budget_start_date" {
  description = "Budget start — must be the first of a month (RFC3339)."
  type        = string
  default     = "2026-10-01T00:00:00Z"
}
