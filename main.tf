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
    ["--node-label", "topology.kubernetes.io/zone=${var.cluster_availability_zone}", "--node-label", "cloud-provider=openstack"],
    var.k3s_master_load_balancer ? ["--tls-san", openstack_lb_loadbalancer_v2.k3s_master.0.vip_address] : [],
    var.cluster_k3s_args,
  )
  common_k3s_server_args = concat(
    local.common_k3s_args,
    ["--kube-apiserver-arg", "enable-bootstrap-token-auth", "--disable", "traefik", "--disable", "local-storage"],
    var.cloud_controller_manager ? ["--disable-cloud-controller", "--disable", "servicelb"] : [],
    var.cilium_cni ? ["--flannel-backend", "none"] : [],
    var.cluster_k3s_server_args,
  )
  common_k3s_agent_args = concat(
    local.common_k3s_args,
    var.cluster_k3s_agent_args
  )
}

module "secgroup" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack/security-group?ref=v4.2.0"

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
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.2.0"

  name                       = "${var.cluster_name}-server1"
  image_name                 = var.cluster_image_name
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_server_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.servers.id
  ephemeral_data_volume      = var.cluster_server_ephemeral_volume
  data_volume_size           = var.cluster_server_volume_size
  data_volume_type           = var.cluster_volume_type
  floating_ip_pool           = var.cluster_server1_floating_ip ? var.cluster_floating_ip_pool : null
  server_properties          = var.cluster_instance_properties
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  k3s_join_existing = !var.cluster_init
  k3s_url           = !var.cluster_init && var.k3s_master_load_balancer ? "https://${openstack_lb_loadbalancer_v2.k3s_master.0.vip_address}" : ""
  cluster_token     = random_password.cluster_token.result
  k3s_args = concat(
    ["server"],
    var.cluster_init ? ["--cluster-init"] : [],
    local.common_k3s_server_args
  )
  k3s_version            = var.cluster_k3s_version
  k3s_channel            = var.cluster_k3s_channel
  bootstrap_token_id     = random_password.cluster_bootstrap_token_id.result
  bootstrap_token_secret = random_password.cluster_bootstrap_token_secret.result
}

locals {
  k3s_server1_url = module.server1.k3s_external_url == "" ? module.server1.k3s_url : module.server1.k3s_external_url
  k3s_server_url  = var.k3s_master_load_balancer ? "https://${openstack_lb_loadbalancer_v2.k3s_master.0.vip_address}" : module.server1.k3s_url
}

module "servers" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.2.0"

  count = var.cluster_servers - 1

  name                       = "${var.cluster_name}-server${count.index + 2}"
  image_name                 = var.cluster_image_name
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_server_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.servers.id
  ephemeral_data_volume      = var.cluster_server_ephemeral_volume
  data_volume_size           = var.cluster_server_volume_size
  data_volume_type           = var.cluster_volume_type
  floating_ip_pool           = var.cluster_servers_floating_ip ? var.cluster_floating_ip_pool : null
  server_properties          = var.cluster_instance_properties
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  k3s_join_existing = true
  k3s_url           = local.k3s_server_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = concat(["server"], local.common_k3s_server_args)
  k3s_version       = var.cluster_k3s_version
  k3s_channel       = var.cluster_k3s_channel

  depends_on = [
    openstack_lb_member_v2.k3s_master1,
  ]
}

module "agents" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.2.0"

  count = var.cluster_size - var.cluster_servers

  name                       = "${var.cluster_name}-agent${count.index + 1}"
  image_name                 = var.cluster_image_name
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_agent_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.agents.0.id
  ephemeral_data_volume      = var.cluster_agent_ephemeral_volume
  data_volume_size           = var.cluster_agent_volume_size
  data_volume_type           = var.cluster_volume_type
  floating_ip_pool           = var.cluster_agents_floating_ip ? var.cluster_floating_ip_pool : null
  server_properties          = var.cluster_instance_properties
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  k3s_join_existing = true
  k3s_url           = local.k3s_server_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = local.common_k3s_agent_args
  k3s_version       = var.cluster_k3s_version
  k3s_channel       = var.cluster_k3s_channel

  depends_on = [
    openstack_lb_member_v2.k3s_master1,
  ]
}

data "k8sbootstrap_auth" "auth" {
  server = var.k3s_master_load_balancer ? local.k3s_server_url : local.k3s_server1_url
  token  = local.cluster_token

  depends_on = [
    module.secgroup,
    openstack_lb_member_v2.k3s_master1,
    openstack_lb_member_v2.k3s_masters,
  ]
}
