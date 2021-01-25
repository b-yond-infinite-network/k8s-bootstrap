output "Ambassador_lb_private_ip" {
  description = "Ambassador Load Balancer private ip"
  value = azurerm_lb.ambassador.frontend_ip_configuration.*.private_ip_address
}