resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = var.log_analytics_workspace_location
  resource_group_name = var.resource_group
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.test.location
  resource_group_name   = var.resource_group
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.k8s_version

  linux_profile {
    admin_username = var.vm_user

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name                  = substr(var.default_node_pool.name, 0, 12)
    orchestrator_version  = var.k8s_version
    node_count            = var.default_node_pool.node_count
    vm_size               = var.default_node_pool.vm_size
    type                  = "VirtualMachineScaleSets"
    availability_zones    = var.default_node_pool.zones
    max_pods              = 250
    os_disk_size_gb       = 128
    vnet_subnet_id        = var.subnet_id
    node_labels           = var.default_node_pool.labels
    node_taints           = var.default_node_pool.taints
    enable_auto_scaling   = var.default_node_pool.cluster_auto_scaling
    min_count             = var.default_node_pool.cluster_auto_scaling_min_count
    max_count             = var.default_node_pool.cluster_auto_scaling_max_count
    enable_node_public_ip = false
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = var.addons.oms_agent
      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    }
    kube_dashboard {
      enabled = var.addons.kubernetes_dashboard
    }
    azure_policy {
      enabled = var.addons.azure_policy
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  # tags = {
  #   Environment = "Development"
  # }
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  for_each = var.additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  name                  = each.value.node_os == "Windows" ? substr(each.key, 0, 6) : substr(each.key, 0, 12)
  orchestrator_version  = var.k8s_version
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  availability_zones    = each.value.zones
  max_pods              = 250
  os_disk_size_gb       = 128
  os_type               = each.value.node_os
  vnet_subnet_id        = var.subnet_id
  node_labels           = each.value.labels
  node_taints           = each.value.taints
  enable_auto_scaling   = each.value.cluster_auto_scaling
  min_count             = each.value.cluster_auto_scaling_min_count
  max_count             = each.value.cluster_auto_scaling_max_count
  enable_node_public_ip = false
}

resource "azurerm_public_ip" "ambassador" {
  name                = "ambassadorIP"
  location            = azurerm_kubernetes_cluster.k8s.location
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  sku                 = "Standard"
  allocation_method   = "Static"
}
