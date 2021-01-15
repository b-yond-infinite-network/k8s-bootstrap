resource "azurerm_lb" "azvm" {
  name                = "loadBalancer"
  location            = var.location
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name                          = "verticalb"
    subnet_id                     = var.subnet_id
    private_ip_address            = var.lb_static_ip
    private_ip_address_allocation = "static"
  }
}

resource "azurerm_lb_backend_address_pool" "azvm" {
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.azvm.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "azvm" {
  count               = var.node_count
  name                = "acctni${count.index}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "VerticaIP"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "azvm" {
  count                   = var.node_count
  network_interface_id    = element(azurerm_network_interface.azvm.*.id, count.index)
  ip_configuration_name   = "VerticaIP"
  backend_address_pool_id = azurerm_lb_backend_address_pool.azvm.id
}

resource "azurerm_managed_disk" "azvm" {
  count                = var.node_count
  name                 = "datadisk_existing_${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
}

resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = var.location
  resource_group_name          = var.resource_group
  platform_fault_domain_count  = var.node_count
  platform_update_domain_count = var.node_count
  managed                      = true
}

resource "azurerm_virtual_machine" "azvm" {
  count                 = var.node_count
  name                  = "acctvm${count.index}"
  location              = var.location
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = var.resource_group
  network_interface_ids = [element(azurerm_network_interface.azvm.*.id, count.index)]
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
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "vert_backup${count.index}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = var.bkp_disk_size
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.azvm.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.azvm.*.id, count.index)
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = element(azurerm_managed_disk.azvm.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "vertica${count.index}"
    admin_username = var.vm_user
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
      key_data = file(var.ssh_public_key)
    }
  }

  # tags = {
  #   environment = var.aks_cluster_name
  # }
}
