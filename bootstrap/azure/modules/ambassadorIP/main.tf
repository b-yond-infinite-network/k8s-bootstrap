resource "azurerm_public_ip" "ambassador" {
  name                = "ambassadorIP"
  location            = var.location
  resource_group_name = var.node_resource_group
  sku                 = "Standard"
  allocation_method   = "Static"
}
