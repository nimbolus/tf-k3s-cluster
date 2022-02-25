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
  repository = "https://nimbolus.github.io/k8s-openstack-node-upgrade-agent"
  chart      = "system-upgrade-controller"
  version    = var.system_upgrade_controller_version
}

resource "kubectl_manifest" "system_upgrade_server_plan" {
  count = var.system_upgrade_controller && var.system_upgrade_k3s_plan ? 1 : 0

  yaml_body = templatefile("${path.module}/manifests/plans/k3s-server.yaml", {
    channel = var.system_upgrade_k3s_plan_channel
  })

  depends_on = [
    helm_release.system_upgrade_controller
  ]
}

resource "kubectl_manifest" "system_upgrade_agent_plan" {
  count = var.system_upgrade_controller && var.system_upgrade_k3s_plan ? 1 : 0

  yaml_body = templatefile("${path.module}/manifests/plans/k3s-agent.yaml", {
    channel = var.system_upgrade_k3s_plan_channel
  })

  depends_on = [
    helm_release.system_upgrade_controller
  ]
}
