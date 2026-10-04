variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "centralus"
}

# Dsv6 (D2s_v6) has both quota and available capacity in Central US for this
# subscription (verified by test-create). North Europe had no VM capacity for
# any family with quota, which is why the whole platform lives in Central US.
variable "vm_size" {
  type    = string
  default = "Standard_D2s_v6"
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
