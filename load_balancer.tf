resource "openstack_lb_loadbalancer_v2" "k3s_master" {
  count = var.k3s_master_load_balancer ? 1 : 0

  name          = "${var.cluster_name}-master"
  vip_subnet_id = var.cluster_subnet_id
}

resource "openstack_lb_pool_v2" "k3s_master" {
  count = var.k3s_master_load_balancer ? 1 : 0

  name            = "${var.cluster_name}-api-server"
  protocol        = "HTTPS"
  lb_method       = "LEAST_CONNECTIONS"
  loadbalancer_id = openstack_lb_loadbalancer_v2.k3s_master.0.id
}

resource "openstack_lb_listener_v2" "k3s_master" {
  count = var.k3s_master_load_balancer ? 1 : 0

  name            = "${var.cluster_name}-api-server"
  protocol        = "HTTPS"
  protocol_port   = 443
  default_pool_id = openstack_lb_pool_v2.k3s_master.0.id
  loadbalancer_id = openstack_lb_loadbalancer_v2.k3s_master.0.id
}

resource "openstack_lb_member_v2" "k3s_master1" {
  count = var.k3s_master_load_balancer ? 1 : 0

  pool_id       = openstack_lb_pool_v2.k3s_master.0.id
  address       = module.server1.node_ip
  protocol_port = 6443
}

resource "openstack_lb_member_v2" "k3s_masters" {
  count = var.k3s_master_load_balancer ? length(module.servers) : 0

  pool_id       = openstack_lb_pool_v2.k3s_master.0.id
  address       = module.servers[count.index].node_ip
  protocol_port = 6443
}

resource "openstack_lb_monitor_v2" "k3s_master" {
  count = var.k3s_master_load_balancer ? 1 : 0

  pool_id     = openstack_lb_pool_v2.k3s_master.0.id
  type        = "TCP"
  delay       = 5
  timeout     = 3
  max_retries = 3
}
