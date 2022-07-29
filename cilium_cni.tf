resource "helm_release" "cilium_cni" {
  count = var.cilium_cni ? 1 : 0

  name       = "cilium"
  namespace  = "kube-system"
  repository = var.cilium_cni_repository
  chart      = var.cilium_cni_chart
  version    = var.cilium_cni_version

  values = [var.cilium_cni_values]
}
