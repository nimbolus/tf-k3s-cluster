output "secgroup_id" {
  value = module.secgroup.id
}

output "k3s_url" {
  value = data.k8sbootstrap_auth.auth.server
}

output "cluster_ca_certificate" {
  value = data.k8sbootstrap_auth.auth.ca_crt
}

output "cluster_token" {
  value = local.cluster_token
}

output "kubeconfig" {
  value = data.k8sbootstrap_auth.auth.kubeconfig
}

output "servers_node_ips" {
  value = concat([module.server1.node_ip], module.servers.*.node_ip)
}

output "servers_node_external_ips" {
  value = concat([module.server1.node_external_ip], module.servers.*.node_external_ip)
}

output "agents_node_ips" {
  value = { for p, v in module.agent_node_pools : p => v["agents_node_ips"] }
}

output "agents_node_external_ips" {
  value = { for p, v in module.agent_node_pools : p => v["agents_node_external_ips"] }
}
