output "bastion_ip" {
  description = "Bastion VM IP"
  value = azurerm_public_ip.bastion
}

output "bastion_username" {
  description = "Bastion VM username"
  value       = var.vm_user
}

