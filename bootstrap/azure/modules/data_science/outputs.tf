output "ds_node_private_ip" {
  description = "private ip addresses of the ds nics"
  value       = azurerm_network_interface.ds.*.private_ip_address
}

output "ds_username" {
  description = "Data Science VM username"
  value       = var.vm_user
}

