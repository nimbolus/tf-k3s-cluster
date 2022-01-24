resource "helm_release" "cilium_cni" {
  count = var.cilium_cni ? 1 : 0

  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_cni_version

  values = [<<-EOT
    ipam:
      mode: kubernetes

    ${var.cilium_cni_values}
    EOT
  ]
}
