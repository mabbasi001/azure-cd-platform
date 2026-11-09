variable "subscription_id" {
  description = "Azure subscription. Leave unset to source from ARM_SUBSCRIPTION_ID; never commit a real id."
  type        = string
  default     = null
}

variable "location" {
  description = "Region for the (metadata-only) resource group; Front Door itself is global."
  type        = string
  default     = "westus3"
}

variable "product" {
  type    = string
  default = "rw"
}

variable "environment" {
  type    = string
  default = "global"
}

variable "tenant_code" {
  type    = string
  default = "e8f"
}

variable "frontdoor_sku" {
  description = "Standard_AzureFrontDoor or Premium_AzureFrontDoor (managed WAF rules need Premium)."
  type        = string
  default     = "Standard_AzureFrontDoor"
}

variable "backend_origin_hostnames" {
  description = "API origin hostnames, primary region first. From `terraform output backend_hostname` in each region's app stack."
  type        = list(string)
}

variable "frontend_origin_hostnames" {
  description = "Web origin hostnames, primary region first. From `terraform output frontend_hostname` in each region's app stack."
  type        = list(string)
}

variable "waf_enabled" {
  type    = bool
  default = true
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}
