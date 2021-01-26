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

variable ambassador_static_ip {
  type = string
}