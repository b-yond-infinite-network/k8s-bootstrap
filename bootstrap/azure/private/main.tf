terraform {
  required_version = ">= 0.13"
}

provider "azurerm" {
  version = "~>2.5" //outbound_type https://github.com/terraform-providers/terraform-provider-azurerm/blob/v2.5.0/CHANGELOG.md
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

data "azurerm_resource_group" "agility" {
  name     = var.aks_resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.aks_network_name
  resource_group_name = var.aks_resource_group_name
}

data "azurerm_subnet" "vnet" {
  name                = var.aks_subnet_name
  resource_group_name = var.aks_resource_group_name
  virtual_network_name = var.aks_network_name
}


module "bastion" {
  source         = "../modules/bastion"
  location       = var.location
  resource_group = var.aks_resource_group_name
  subnet_id      = data.azurerm_subnet.vnet.id
  vm_user        = var.ssh_user
  ssh_public_key = var.ssh_public_key
}

module "data_science" {
  source          = "../modules/data_science"
  instances_count = var.data_science_enabled ? 1 : 0
  location        = var.location
  resource_group  = var.aks_resource_group_name
  subnet_id       = data.azurerm_subnet.vnet.id
  vm_user         = var.ssh_user
  ssh_public_key  = var.ssh_public_key
  flavor          = var.data_science_flavor
  disk_size       = var.data_science_disk_size
}

module "vertica_cluster" {
  source         = "../modules/vertica_cluster"
  node_count     = var.vertica_node_count
  location       = var.location
  resource_group = var.vertica_resource_group_name
  subnet_id      = data.azurerm_subnet.vnet.id
  vm_user        = var.ssh_user
  ssh_public_key = var.ssh_public_key
  flavor         = var.vertica_flavor
  disk_size      = var.vertica_disk_size
  bkp_disk_size  = var.vertica_bkp_disk_size
  lb_static_ip   = var.vertica_lb_static_ip
}

module "k8s_cluster" {
  source                           = "../modules/aks"
  location                         = var.location
  client_id                        = var.client_id
  client_secret                    = var.client_secret
  resource_group                   = var.aks_resource_group_name
  node_resource_group              = var.aks_node_resource_group
  private_cluster_enabled          = var.aks_private_cluster_enabled
  cluster_name                     = var.aks_cluster_name
  k8s_version                      = var.aks_k8s_version
  default_node_pool                = var.aks_default_node_pool
  additional_node_pools            = var.aks_additional_node_pools
  subnet_id                        = data.azurerm_subnet.vnet.id
  vm_user                          = var.ssh_user
  ssh_public_key                   = var.ssh_public_key
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_location = var.log_analytics_workspace_location
  log_analytics_workspace_sku      = var.log_analytics_workspace_sku
  addons                           = var.aks_addons
}


module "ambassador" {
  source         = "../modules/ambassadorlb"
  location       = var.location
  resource_group = data.azurerm_resource_group.agility.name
  subnet_id      = data.azurerm_subnet.vnet.id
  ambassador_static_ip = var.aks_ambassador_static_ip
}