variable subnet_id {
  description = "ID of subnet where Data Science VM will be installed"
  type        = string
}

variable "node_count" {}
variable "flavor" {}
variable "disk_size" {}
variable "bkp_disk_size" {}

variable "vm_user" {
  default = "ubuntu"
}

variable "ssh_public_key" {
  default = "./id_rsa.pub"
}

variable resource_group {}

variable location {
}

variable "lb_static_ip" {
  description = "Load Balancer Fixed Ip in front of Vertica cluster."
  type        = string
}
