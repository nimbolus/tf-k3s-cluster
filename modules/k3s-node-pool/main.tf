resource "openstack_compute_servergroup_v2" "agents" {
  name     = "${var.cluster_name}-${var.node_pool_name}-agents"
  policies = [var.node_pool["server_group_policy"]]
}

module "agents" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.2.3"

  count = var.node_pool["size"]

  name                       = "${var.cluster_name}-${var.node_pool_name}-agent${count.index + 1}"
  availability_zone          = var.node_pool["availability_zone"]
  network_id                 = var.node_pool["network_id"]
  subnet_id                  = var.node_pool["subnet_id"]
  image_name                 = var.node_pool["image_name"]
  image_id                   = var.node_pool["image_id"]
  image_scsi_bus             = var.node_pool["image_scsi_bus"]
  flavor_name                = var.node_pool["flavor_name"]
  ephemeral_data_volume      = var.node_pool["ephemeral_data_volume"]
  data_volume_type           = var.node_pool["data_volume_type"]
  data_volume_size           = var.node_pool["data_volume_size"]
  server_properties          = lookup(var.node_pool, "instance_properties", var.cluster_instance_properties)
  floating_ip_pool           = var.node_pool["floating_ip"] ? var.cluster_floating_ip_pool : null
  keypair_name               = var.cluster_key_pair
  security_group_ids         = var.security_group_ids
  server_group_id            = openstack_compute_servergroup_v2.agents.id
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  k3s_join_existing = true
  k3s_url           = var.k3s_url
  cluster_token     = var.cluster_token
  k3s_args = concat(
    var.cluster_k3s_args,
    ["--node-label", "topology.kubernetes.io/zone=${var.node_pool["availability_zone"]}"],
    lookup(var.node_pool, "k3s_args", var.cluster_k3s_agent_args),
  )
  k3s_version     = var.node_pool["k3s_version"]
  k3s_channel     = var.node_pool["k3s_channel"]
  k3s_install_url = var.node_pool["k3s_install_url"]
}
