output "endpoint_url" {
  description = "Public global entry point for the application."
  value       = module.frontdoor.endpoint_url
}

output "endpoint_hostname" {
  value = module.frontdoor.endpoint_hostname
}
