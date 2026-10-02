variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
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
