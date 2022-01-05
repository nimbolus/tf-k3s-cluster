output "secgroup_id" {
  value = module.secgroup.id
}

output "k3s_url" {
  value = module.server1.k3s_external_url == "" ? module.server1.k3s_url : module.server1.k3s_external_url
}

output "cluster_token" {
  value = local.cluster_token
}

output "servers_node_ips" {
  value = concat([module.server1.node_ip], module.servers.*.node_ip)
}

output "servers_node_external_ips" {
  value = concat([module.server1.node_external_ip], module.servers.*.node_external_ip)
}

output "agents_node_ips" {
  value = module.agents.*.node_ip
}

output "agents_node_external_ips" {
  value = module.agents.*.node_external_ip
}
