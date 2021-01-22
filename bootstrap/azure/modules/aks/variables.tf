variable "client_id" {
  description = "Azure Principal Client Id."
  type        = string
}

variable "client_secret" {
  description = "Azure Principal Client Secret."
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}
variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
}
variable "private_cluster_enabled" {
  description = "Create a Private AKS cluster"
  type        = bool
}

variable subnet_id {
  description = "ID of subnet where Kubernetes Nodes will be installed"
  type        = string
}

variable "vm_user" {
  description = "VM Username to connect to all AKS nodes."
  type        = string
}

variable "ssh_public_key" {
  description = "Public key for vm_user to connect with SSH."
  type        = string
}

variable resource_group {
  description = "Name of the AKS cluster resource group"
  type        = string
}

variable node_resource_group {
  description = "Name of the AKS cluster node resource group"
  type        = string
}

variable "location" {
  description = "Azure region of the AKS cluster"
  type        = string
}

variable "default_node_pool" {
  description = "The object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones."
  type = object({
    name                           = string
    node_count                     = number
    vm_size                        = string
    zones                          = list(string)
    labels                         = map(string)
    taints                         = list(string)
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
  })
}

variable "additional_node_pools" {
  description = "The map object to configure one or several additional node pools with number of worker nodes, worker node VM size and Availability Zones."
  type = map(object({
    node_count                     = number
    vm_size                        = string
    zones                          = list(string)
    labels                         = map(string)
    taints                         = list(string)
    node_os                        = string
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
  }))
  default = {
  }
}

variable "addons" {
  description = "Defines which addons will be activated."
  type = object({
    oms_agent            = bool
    kubernetes_dashboard = bool
    azure_policy         = bool
  })
}

variable log_analytics_workspace_name {
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
}

