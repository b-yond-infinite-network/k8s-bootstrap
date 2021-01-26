output "kube_config" {
  value = module.k8s_cluster.kube_config
}

output "Ambassador_lb_private_ip" {
  value = module.ambassador.Ambassador_lb_private_ip
}

output "ds_node_private_ip" {
  value = module.data_science.ds_node_private_ip
}

output "ds_username" {
  value = module.data_science.ds_username
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}

output "bastion_username" {
  value = module.bastion.bastion_username
}

output "vertica_node_private_ips" {
  value = module.vertica_cluster.vertica_node_private_ips
}

output "vertica_lb_private_ip" {
  value = module.vertica_cluster.vertica_lb_private_ip
}
