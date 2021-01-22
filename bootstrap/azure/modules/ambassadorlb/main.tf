resource "azurerm_lb" "ambassador" {
  name                = "ambassador"
  location            = var.location
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name                          = "ambassadorlb"
    subnet_id                     = var.subnet_id
    private_ip_address            = var.ambassador_static_ip
    private_ip_address_allocation = "static"
  }
}