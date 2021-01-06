variable resource_group {
  type = string
}

variable location {
  type = string
}

variable subnet_id {
  description = "ID of subnet where Data Science VM will be installed"
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

variable flavor {
  description = "Data Science VM Flavor"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "disk_size" {
  default = 1023
}

variable instances_count {
  default = 1
}
