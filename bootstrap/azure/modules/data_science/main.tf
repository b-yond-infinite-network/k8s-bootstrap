# # refer to a resource group
# data "azurerm_resource_group" "ds" {
#   name = var.vertica_resource_group_name
#   depends_on = [
#     azurerm_resource_group.azvm,
#   ]
# }

# #refer to a subnet
# data "azurerm_subnet" "ds" {
#   name                 = var.vertica_subnet_name
#   virtual_network_name = var.vertica_network_name
#   resource_group_name  = var.vertica_resource_group_name
#   depends_on = [
#     azurerm_subnet.azvm,
#   ]
# }

resource "azurerm_network_interface" "ds" {
  count               = var.instances_count
  name                = "ds-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "dsIP"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "ds" {
  count                 = var.instances_count
  name                  = "ds"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.ds[0].id]
  vm_size               = var.flavor

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "dsdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "dsdatadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = var.disk_size
  }

  os_profile {
    computer_name  = "ds"
    admin_username = var.vm_user
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
      key_data = file(var.ssh_public_key)
    }
  }

}
