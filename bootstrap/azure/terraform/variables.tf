variable "client_id" {}
variable "client_secret" {}
variable "cluster_name" {}
variable "k8s_version" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "regional_enabled" {}
variable "network" {}
variable "subnet" {}
variable "subnet_cidr" {}
variable "subnetwork_region" {}
variable "secondary_pod_range" {}
variable "secondary_service_range" {}

variable "ssh_public_key" {
    default = "./id_rsa.pub"
}

variable "ssh_private_key" {
    default = "./id_rsa"
}

variable "dns_prefix" {
    default = "my-dns"
}

variable resource_group_name {
    default = "my-resource-group"
}

variable dnp_name {}
variable dnp_node_count {}
variable dnp_vm_size {}
variable dnp_type {}
variable dnp_availability_zones {}
variable dnp_max_pods {}
variable dnp_os_disk_size_gb {}
variable dnp_enable_auto_scaling {}
variable dnp_min_count {}
variable dnp_max_count {}

variable location {
    default = "East US"
}

variable log_analytics_workspace_name {
    default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}