resource "helm_release" "cilium_cni" {
  count = var.cilium_cni ? 1 : 0

  name       = "cilium"
  namespace  = "kube-system"
  repository = var.cilium_cni_repository
  chart      = var.cilium_cni_chart
  version    = var.cilium_cni_version

  values = concat(
    [var.cilium_cni_values],
    var.k3s_master_load_balancer ? [<<-EOT
      k8sServiceHost: ${openstack_lb_loadbalancer_v2.k3s_master.0.vip_address}
      k8sServicePort: 443
      EOT
    ] : [],
  )
}
