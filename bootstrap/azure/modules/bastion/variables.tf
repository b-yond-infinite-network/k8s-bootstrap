variable resource_group {
  type = string
}

variable location {
  type = string
}

variable subnet_id {
  description = "ID of subnet where bastion VM will be installed"
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