variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "northeurope"
}

# BASv2 (B2als_v2) is the family with available capacity in North Europe for
# this subscription; it needs a one-time "Standard BASv2 Family vCPUs" quota
# grant. Older BS/D families have quota but no capacity in-region.
variable "vm_size" {
  type    = string
  default = "Standard_B2als_v2"
}

variable "ssh_public_key" {
  description = "SSH public key for the runner VM admin user."
  type        = string
}

variable "admin_ssh_cidr" {
  description = "CIDR allowed to SSH to the runner (e.g. your IP/32)."
  type        = string
  default     = null
}
