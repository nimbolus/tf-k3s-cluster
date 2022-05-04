output "agents_node_ips" {
  value = module.agents.*.node_ip
}

output "agents_node_external_ips" {
  value = module.agents.*.node_external_ip
}
