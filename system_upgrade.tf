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

resource "kubernetes_secret" "node_upgrade_channel" {
  count = var.system_upgrade_node_channel ? 1 : 0

  metadata {
    name      = "openstack-clouds"
    namespace = kubernetes_namespace.system_upgrade.0.metadata.0.name
  }

  data = {
    "clouds.yaml" = <<-EOT
      clouds:
        openstack:
          auth:
            auth_url: "${var.openstack_auth_url}"
            application_credential_id: "${var.openstack_application_credential_id}"
            application_credential_secret: "${var.openstack_application_credential_secret}"
          auth_type: "v3applicationcredential"
          identity_api_version: 3
          interface: "public"
          region_name: "${var.openstack_region}"
      EOT
  }
}

resource "helm_release" "node_upgrade_channel" {
  count = var.system_upgrade_node_channel ? 1 : 0

  name       = "node-upgrade-channel"
  namespace  = kubernetes_namespace.system_upgrade.0.metadata.0.name
  repository = "https://nimbolus.github.io/k8s-openstack-node-upgrade-agent"
  chart      = "node-upgrade-channel"
  version    = var.system_upgrade_node_channel_version
  values = [<<-EOT
    secret:
      create: false
      name: ${kubernetes_secret.node_upgrade_channel.0.metadata.0.name}
    EOT
  ]
}

resource "kubectl_manifest" "node_upgrade_plan" {
  count = var.system_upgrade_node_channel ? 1 : 0

  yaml_body = templatefile("${path.module}/manifests/plans/openstack-instance.yaml", {
    secret_name          = kubernetes_secret.node_upgrade_channel.0.metadata.0.name
    image_tag            = var.system_upgrade_node_upgrade_plan_image_tag
    openstack_image_name = var.cluster_image_name
  })

  depends_on = [
    helm_release.system_upgrade_controller
  ]
}
