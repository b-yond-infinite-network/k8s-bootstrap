output "vertica_node_private_ips" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.azvm.*.private_ip_address
}

output "vertica_lb_private_ip" {
  description = "Vertica Load Balancer private ip"
  value = azurerm_lb.azvm.frontend_ip_configuration.*.private_ip_address
}