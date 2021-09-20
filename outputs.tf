output "secgroup_id" {
  value = module.secgroup.id
}

output "k3s_url" {
  value = module.server1.k3s_external_url == "" ? module.server1.k3s_url : module.server1.k3s_external_url
}

output "cluster_token" {
  value = local.cluster_token
}
