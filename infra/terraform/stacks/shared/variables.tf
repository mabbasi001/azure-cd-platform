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

variable "address_space" {
  description = "VNet CIDR. Use a non-overlapping range per region so VNets can be peered for DR."
  type        = string
  default     = "10.10.0.0/16"
}

variable "acr_sku" {
  description = "Container registry SKU. Geo-replication requires Premium."
  type        = string
  default     = "Basic"
}

variable "acr_georeplication_locations" {
  description = "Regions to geo-replicate the registry to (Premium only)."
  type        = list(string)
  default     = []
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
