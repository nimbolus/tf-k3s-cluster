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

  common_k3s_server_args = concat(
    var.cluster_k3s_args,
    ["--node-label", "topology.kubernetes.io/zone=${var.cluster_availability_zone}"],
    ["--kube-apiserver-arg", "enable-bootstrap-token-auth", "--disable", "traefik", "--disable", "local-storage"],
    var.cluster_server_taint ? ["--node-taint", "node-role.kubernetes.io/master=true:NoSchedule"] : [],
    var.k3s_master_load_balancer ? ["--tls-san", openstack_lb_loadbalancer_v2.k3s_master.0.vip_address] : [],
    var.cloud_controller_manager ? ["--disable-cloud-controller", "--disable", "servicelb"] : [],
    var.cilium_cni ? ["--flannel-backend", "none"] : [],
    var.cluster_k3s_server_args,
  )

  cluster_agent_node_pools = defaults(var.cluster_agent_node_pools, {
    availability_zone     = var.cluster_availability_zone
    network_id            = var.cluster_network_id
    subnet_id             = var.cluster_subnet_id
    image_name            = var.cluster_image_name
    image_id              = var.cluster_image_id
    image_scsi_bus        = var.cluster_image_scsi_bus
    flavor_name           = var.cluster_flavor_name
    ephemeral_data_volume = var.cluster_ephemeral_data_volume
    data_volume_type      = var.cluster_data_volume_type
    data_volume_size      = var.cluster_data_volume_size
    server_group_policy   = var.cluster_server_group_policy
    floating_ip           = false
    k3s_version           = var.cluster_k3s_version
    k3s_channel           = var.cluster_k3s_channel
    k3s_install_url       = var.cluster_k3s_install_url
  })
}

module "secgroup" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack/security-group?ref=v4.2.4"

  security_group_name    = "${var.cluster_name}-k3s"
  enable_ipv6            = var.cluster_enable_ipv6
  allow_remote_prefix_v6 = var.cluster_allow_remote_prefix_v6
}

resource "openstack_compute_servergroup_v2" "servers" {
  name     = "${var.cluster_name}-servers"
  policies = [var.cluster_server_group_policy]
}

module "server1" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.2.4"

  name                       = "${var.cluster_name}-server1"
  image_name                 = var.cluster_image_name
  image_id                   = var.cluster_image_id
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.servers.id
  ephemeral_data_volume      = var.cluster_ephemeral_data_volume
  data_volume_size           = var.cluster_data_volume_size
  data_volume_type           = var.cluster_data_volume_type
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
  k3s_install_url        = var.cluster_k3s_install_url
  bootstrap_token_id     = random_password.cluster_bootstrap_token_id.result
  bootstrap_token_secret = random_password.cluster_bootstrap_token_secret.result
}

locals {
  k3s_server1_url = module.server1.k3s_external_url == "" ? module.server1.k3s_url : module.server1.k3s_external_url
  k3s_server_url  = var.k3s_master_load_balancer ? "https://${openstack_lb_loadbalancer_v2.k3s_master.0.vip_address}" : module.server1.k3s_url
}

module "servers" {
  source = "git::https://github.com/nimbolus/tf-k3s.git//k3s-openstack?ref=v4.2.4"

  count = var.cluster_servers - 1

  name                       = "${var.cluster_name}-server${count.index + 2}"
  image_name                 = var.cluster_image_name
  image_id                   = var.cluster_image_id
  image_scsi_bus             = var.cluster_image_scsi_bus
  flavor_name                = var.cluster_flavor_name
  availability_zone          = var.cluster_availability_zone
  keypair_name               = var.cluster_key_pair
  network_id                 = var.cluster_network_id
  subnet_id                  = var.cluster_subnet_id
  security_group_ids         = [module.secgroup.id]
  server_group_id            = openstack_compute_servergroup_v2.servers.id
  ephemeral_data_volume      = var.cluster_ephemeral_data_volume
  data_volume_size           = var.cluster_data_volume_size
  data_volume_type           = var.cluster_data_volume_type
  floating_ip_pool           = var.cluster_servers_floating_ip ? var.cluster_floating_ip_pool : null
  server_properties          = var.cluster_instance_properties
  server_stop_before_destroy = var.cluster_instance_stop_before_destroy

  k3s_join_existing = true
  k3s_url           = local.k3s_server_url
  cluster_token     = random_password.cluster_token.result
  k3s_args          = concat(["server"], local.common_k3s_server_args)
  k3s_version       = var.cluster_k3s_version
  k3s_channel       = var.cluster_k3s_channel
  k3s_install_url   = var.cluster_k3s_install_url

  depends_on = [
    openstack_lb_member_v2.k3s_master1,
  ]
}

module "agent_node_pools" {
  source = "./modules/k3s-node-pool"

  for_each = local.cluster_agent_node_pools

  cluster_name                         = var.cluster_name
  cluster_key_pair                     = var.cluster_key_pair
  cluster_instance_stop_before_destroy = var.cluster_instance_stop_before_destroy
  cluster_floating_ip_pool             = var.cluster_floating_ip_pool
  cluster_token                        = random_password.cluster_token.result
  cluster_k3s_args                     = var.cluster_k3s_args
  cluster_k3s_agent_args               = var.cluster_k3s_agent_args
  cluster_instance_properties          = var.cluster_instance_properties

  k3s_url            = local.k3s_server_url
  security_group_ids = [module.secgroup.id]

  node_pool_name = each.key
  node_pool      = each.value
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
