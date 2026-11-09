variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "target_resource_id" {
  description = "App Service plan to autoscale."
  type        = string
}

variable "minimum" {
  type    = number
  default = 2
}

variable "maximum" {
  type    = number
  default = 3
}

variable "cpu_scale_out_threshold" {
  type    = number
  default = 70
}

variable "cpu_scale_in_threshold" {
  type    = number
  default = 30
}

variable "http_queue_scale_out_threshold" {
  description = "Scale out when the HTTP request queue exceeds this length. Null disables the rule."
  type        = number
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
