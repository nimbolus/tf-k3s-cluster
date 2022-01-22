resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

resource "random_password" "cluster_bootstrap_token_id" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "cluster_bootstrap_token_secret" {
  length  = 16
  upper   = false
  special = false
}

locals {
  cluster_token = "${random_password.cluster_bootstrap_token_id.result}.${random_password.cluster_bootstrap_token_secret.result}"
  common_k3s_args = concat(
    ["--node-label", "az=${var.cluster_availability_zone}"],
    var.cluster_k3s_args,
  )
  common_k3s_server_args = concat(
    local.common_k3s_args,
    ["--kube-apiserver-arg", "enable-bootstrap-token-auth", "--disable", "traefik", "--disable", "local-storage"],
    var.cluster_k3s_server_args,
  )
  common_k3s_agent_args = concat(
    local.common_k3s_args,
    var.cluster_k3s_agent_args
  )
}

module "secgroup" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack/security-group?ref=v4.1.3"

  security_group_name    = "${var.cluster_name}-k3s"
  enable_ipv6            = var.cluster_enable_ipv6
  allow_remote_prefix_v6 = var.cluster_allow_remote_prefix_v6
}

resource "openstack_compute_servergroup_v2" "servers" {
  name     = "${var.cluster_name}-servers"
  policies = [var.cluster_servers_server_group_policy]
}

resource "openstack_compute_servergroup_v2" "agents" {
  count = var.cluster_size - var.cluster_servers > 0 ? 1 : 0

  name     = "${var.cluster_name}-agents"
  policies = [var.cluster_agents_server_group_policy]
}

module "server1" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.1.3"

  name                       = "${var.cluster_name}-server1"
  image_name                 = var.cluster_image_name
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.servers.id
  data_volume_size           = var.cluster_volume_size
  data_volume_type           = var.cluster_volume_type
  floating_ip_pool           = var.cluster_server1_floating_ip ? var.cluster_floating_ip_pool : null
  server_properties          = var.cluster_instance_properties
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  cluster_token          = random_password.cluster_token.result
  k3s_args               = concat(["server", "--cluster-init"], local.common_k3s_server_args)
  k3s_version            = var.cluster_k3s_version
  bootstrap_token_id     = random_password.cluster_bootstrap_token_id.result
  bootstrap_token_secret = random_password.cluster_bootstrap_token_secret.result
}

module "servers" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.1.3"

  count = var.cluster_servers - 1

  name                       = "${var.cluster_name}-server${count.index + 2}"
  image_name                 = var.cluster_image_name
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.servers.id
  data_volume_size           = var.cluster_volume_size
  data_volume_type           = var.cluster_volume_type
  floating_ip_pool           = var.cluster_servers_floating_ip ? var.cluster_floating_ip_pool : null
  server_properties          = var.cluster_instance_properties
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = concat(["server"], local.common_k3s_server_args)
  k3s_version       = var.cluster_k3s_version
}

module "agents" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.1.3"

  count = var.cluster_size - var.cluster_servers

  name                       = "${var.cluster_name}-agent${count.index + 1}"
  image_name                 = var.cluster_image_name
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.agents.0.id
  data_volume_size           = var.cluster_volume_size
  data_volume_type           = var.cluster_volume_type
  floating_ip_pool           = var.cluster_agents_floating_ip ? var.cluster_floating_ip_pool : null
  server_properties          = var.cluster_instance_properties
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = local.common_k3s_agent_args
  k3s_version       = var.cluster_k3s_version
}
