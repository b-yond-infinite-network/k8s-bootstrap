# Create public IPs
resource "azurerm_public_ip" "bastion" {
  name                = "bastion-pub-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
}

# create a network interface
resource "azurerm_network_interface" "bastion" {
  name                = "nic-bastion"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "bastionConfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "bastion" {
  name                  = "bastion"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.bastion.id]
  vm_size               = "Standard_DS1_v2"

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
    name              = "bastiondisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "bastion"
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
