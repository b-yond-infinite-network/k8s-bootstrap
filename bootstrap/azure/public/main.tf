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

resource "azurerm_resource_group" "vertica" {
  name     = var.vertica_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "k8s" {
  name     = var.aks_resource_group_name
  location = var.location
}

module "aks_network" {
  source              = "../modules/vnet"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = var.location
  vnet_name           = var.aks_network_name
  address_space       = var.aks_network_cidr
  subnets = [
    {
      name : var.aks_subnet_name
      address_prefixes : var.aks_subnet_cidr
    }
  ]
}

module "vertica_network" {
  source              = "../modules/vnet"
  resource_group_name = azurerm_resource_group.vertica.name
  location            = var.location
  vnet_name           = var.vertica_network_name
  address_space       = var.vertica_network_cidr
  subnets = [
    {
      name : var.vertica_subnet_name
      address_prefixes : var.vertica_subnet_cidr
    }
  ]
}

module "vnet_peering" {
  source              = "../modules/vnet_peering"
  vnet_1_name         = var.vertica_network_name
  vnet_1_id           = module.vertica_network.vnet_id
  vnet_1_rg           = azurerm_resource_group.vertica.name
  vnet_2_name         = var.aks_network_name
  vnet_2_id           = module.aks_network.vnet_id
  vnet_2_rg           = azurerm_resource_group.k8s.name
  peering_name_1_to_2 = "vertica2aks"
  peering_name_2_to_1 = "aks2vertica"
}


module "bastion" {
  source         = "../modules/bastion"
  location       = var.location
  resource_group = azurerm_resource_group.vertica.name
  subnet_id      = module.vertica_network.subnet_ids[var.vertica_subnet_name]
  vm_user        = var.ssh_user
  ssh_public_key = var.ssh_public_key
}

module "data_science" {
  source          = "../modules/data_science"
  instances_count = var.data_science_enabled ? 1 : 0
  location        = var.location
  resource_group  = azurerm_resource_group.vertica.name
  subnet_id       = module.vertica_network.subnet_ids[var.vertica_subnet_name]
  vm_user         = var.ssh_user
  ssh_public_key  = var.ssh_public_key
  flavor          = var.data_science_flavor
  disk_size       = var.data_science_disk_size
}

module "vertica_cluster" {
  source         = "../modules/vertica_cluster"
  node_count     = var.vertica_node_count
  location       = var.location
  resource_group = azurerm_resource_group.vertica.name
  subnet_id      = module.vertica_network.subnet_ids[var.vertica_subnet_name]
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
  resource_group                   = azurerm_resource_group.k8s.name
  node_resource_group              = var.aks_node_resource_group
  private_cluster_enabled          = var.aks_private_cluster_enabled
  cluster_name                     = var.aks_cluster_name
  k8s_version                      = var.aks_k8s_version
  default_node_pool                = var.aks_default_node_pool
  additional_node_pools            = var.aks_additional_node_pools
  subnet_id                        = module.aks_network.subnet_ids[var.aks_subnet_name]
  vm_user                          = var.ssh_user
  ssh_public_key                   = var.ssh_public_key
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_location = var.log_analytics_workspace_location
  log_analytics_workspace_sku      = var.log_analytics_workspace_sku
  addons                           = var.aks_addons
}

module "ambassador" {
  source         = "../modules/ambassadorIP"
  location       = var.location
  node_resource_group = module.k8s_cluster.node_resource_group
  subnet_id      = module.aks_network.subnet_ids[var.aks_subnet_name]
}