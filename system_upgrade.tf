resource "kubernetes_namespace" "system_upgrade" {
  count = var.system_upgrade_controller ? 1 : 0

  metadata {
    name = "system-upgrade"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.labels,
      metadata.0.annotations,
    ]
  }
}

resource "helm_release" "system_upgrade_controller" {
  count = var.system_upgrade_controller ? 1 : 0

  name       = "system-upgrade-controller"
  namespace  = kubernetes_namespace.system_upgrade.0.metadata.0.name
  repository = "https://nimbolus.github.io/helm-charts"
  chart      = "system-upgrade-controller"
  version    = var.system_upgrade_controller_version
}
