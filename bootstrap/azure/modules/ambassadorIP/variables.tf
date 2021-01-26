
variable location {
  type = string
}

variable node_resource_group {
  description = "K8s Node Resource Group"
  type        = string
}

variable subnet_id {
  description = "ID of subnet where bastion VM will be installed"
  type        = string
}