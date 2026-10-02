output "public_ip" {
  value = azurerm_public_ip.this.ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.this.name
}

output "admin_username" {
  value = var.admin_username
}

output "private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}
