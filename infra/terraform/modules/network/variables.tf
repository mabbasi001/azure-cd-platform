variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  description = "Map of subnet name => settings."
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name    = string
      service = string
      actions = list(string)
    }))
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
