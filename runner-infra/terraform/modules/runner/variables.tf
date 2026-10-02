variable "name" {
  description = "Base name, e.g. rw-shared-runner."
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "identity_id" {
  description = "User-assigned managed identity to attach (for ACR pull etc.)."
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}

variable "admin_ssh_cidr" {
  description = "CIDR allowed to reach SSH. Set to your IP; defaults to none."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
