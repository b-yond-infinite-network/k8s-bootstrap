## GENERAL VARIABLES
variable "subscription_id" {
  description = "Azure Subscription Id."
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant Id."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "client_id" {
  description = "Azure Principal Client Id."
  type        = string
}

variable "client_secret" {
  description = "Azure Principal Client Secret."
  type        = string
}

variable "ssh_user" {
  description = "VM Username to connect to all nodes (aks, vertica and utility VMs)."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Public key for vm_user to connect with SSH."
  type        = string
  default     = "./id_rsa.pub"
}

variable "ssh_private_key" {
  description = "Private key for vm_user to connect with SSH."
  type        = string
  default     = "./id_rsa"
}

# AKS CLUSTER VARIABLES
variable aks_resource_group_name {
  description = "The AKS resource group name to be used"
  default     = "aks-resource-group"
}

variable "aks_network_name" {
  type = string
}
variable "aks_network_cidr" {
  type    = list(string)
  default = ["10.240.0.0/16"]
}

variable "aks_subnet_name" {
  type = string
}
variable "aks_subnet_cidr" {
  type    = list(string)
  default = ["10.240.1.0/24"]
}

variable "aks_node_resource_group" {
  type        = string
}

variable "aks_private_cluster_enabled" {
  type        = bool
}

variable "aks_cluster_name" {
  type = string
}
variable "aks_k8s_version" {
  type = string
}

variable "aks_default_node_pool" {
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

variable "aks_additional_node_pools" {
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

variable "aks_addons" {
  description = "Defines which addons will be activated."
  type = object({
    oms_agent            = bool
    kubernetes_dashboard = bool
    azure_policy         = bool
  })
  default = {
    oms_agent            = true
    kubernetes_dashboard = true
    azure_policy         = false
  }
}

variable aks_ambassador_static_ip {
  description = "Load Balancer Fixed Ip for ambassador."
  type        = string
  default     = "10.240.1.99"
}

variable log_analytics_workspace_name {
  default = "testLogAnalyticsWorkspaceName"
}

variable log_analytics_workspace_location {
  default = "eastus"
}

variable log_analytics_workspace_sku {
  type    = string
  default = "PerGB2018"
}

## VERTICA CLUSTER VARIABLES
variable "vertica_network_name" {
  type = string
}
variable "vertica_network_cidr" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}
variable "vertica_subnet_name" {}

variable "vertica_subnet_cidr" {
  type    = list(string)
  default = ["10.10.1.0/24"]
}

variable vertica_resource_group_name {
  description = "The Vertica resource group name to be created"
  default     = "vertica-resource-group"
}

variable "vertica_node_count" {}
variable "vertica_flavor" {}
variable "vertica_disk_size" {}
variable "vertica_bkp_disk_size" {}

variable "vertica_lb_static_ip" {
  description = "Load Balancer Fixed Ip in front of Vertica cluster."
  type        = string
}

# DATA SCIENCE VARIABLES
variable "data_science_enabled" {
  description = "If set to true, create ds server"
  type        = bool
  default     = false
}

variable "data_science_flavor" {
  description = "If set to true, create ds server"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "data_science_disk_size" {
  description = "VM attached disk size in GB"
  type        = number
  default     = 1023
}

