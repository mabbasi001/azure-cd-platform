variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  description = "Subnet that hosts the private endpoint NIC."
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource the endpoint connects to."
  type        = string
}

variable "subresource_names" {
  description = "Target sub-resources, e.g. [\"vault\"] for Key Vault."
  type        = list(string)
}

variable "private_dns_zone_name" {
  description = "Private DNS zone, e.g. privatelink.vaultcore.azure.net."
  type        = string
}

variable "vnet_id" {
  description = "VNet linked to the private DNS zone for resolution."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
