locals {
  cloud_controller_manager_version_matrix = {
    # kubernetes version => cloud-controller-manager chart version
    "v1.20" : "1.0.2",
    "v1.21" : "1.0.2",
    "v1.22" : "1.1.2",
    "v1.23" : "1.2.0",
    "v1.24" : "2.24.0",
    "v1.25" : "2.25.1",
    "v1.26" : "2.26.5",
    "v1.27" : "2.27.6",
    "v1.28" : "2.28.3",
  }
  cloud_controller_manager_version = var.cloud_controller_manager_version != null ? var.cloud_controller_manager_version : local.cloud_controller_manager_version_matrix[var.kubernetes_version]

  cinder_csi_version_matrix = {
    # kubernetes version => cinder-csi chart version
    "v1.20" : "1.2.14",
    "v1.21" : "1.3.9",
    "v1.22" : "1.4.9",
    "v1.23" : "2.1.1",
    "v1.24" : "2.24.0",
    "v1.25" : "2.25.1",
    "v1.26" : "2.26.0",
    "v1.27" : "2.27.3",
    "v1.28" : "2.28.1",
  }
  cinder_csi_version = var.cinder_csi_version != null ? var.cinder_csi_version : local.cinder_csi_version_matrix[var.kubernetes_version]
}

resource "kubernetes_secret" "cloud_config" {
  count = var.cloud_controller_manager || var.cinder_csi ? 1 : 0

  metadata {
    name      = "openstack-cloud-config"
    namespace = "kube-system"
  }

  data = {
    "cloud.conf" = <<-EOT
      [Global]
      auth-url=${var.openstack_auth_url}
      region=${var.openstack_region}
      application-credential-id=${var.openstack_application_credential_id}
      application-credential-secret=${var.openstack_application_credential_secret}
      %{if var.cloud_controller_manager_router_id != null}
      [Route]
      router-id=${var.cloud_controller_manager_router_id}
      %{endif}
      [LoadBalancer]
      subnet-id=${var.cluster_subnet_id}
      create-monitor=${var.cloud_controller_manager_lb_monitor}
      enable-ingress-hostname=${var.cloud_controller_manager_ingress_hostname}
      EOT
    # cloud config for cinder-csi releases <1.24
    cloud-config = <<-EOT
      [Global]
      auth-url=${var.openstack_auth_url}
      region=${var.openstack_region}
      application-credential-id=${var.openstack_application_credential_id}
      application-credential-secret=${var.openstack_application_credential_secret}
      EOT
  }
}

locals {
  cloud_controller_manager_extra_args = <<-EOT
  %{if var.cloud_controller_manager_cluster_cidr != null~}
  - --cluster-cidr=${var.cloud_controller_manager_cluster_cidr}
  %{endif~}
  EOT
}

resource "helm_release" "cloud_controller_manager" {
  count = var.cloud_controller_manager ? 1 : 0

  repository = "https://kubernetes.github.io/cloud-provider-openstack"
  chart      = "openstack-cloud-controller-manager"
  name       = "cloud-controller-manager"
  namespace  = "kube-system"
  version    = local.cloud_controller_manager_version
  values = [<<-EOT
    nodeSelector:
      node-role.kubernetes.io/control-plane: "true"

    tolerations:
      - key: node.cloudprovider.kubernetes.io/uninitialized
        value: "true"
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        value: "true"
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        value: "true"
        effect: NoSchedule
      - key: node-role.kubernetes.io/etcd
        value: "true"
        effect: NoExecute
    %{if local.cloud_controller_manager_extra_args != null}
    controllerExtraArgs: |-
    ${local.cloud_controller_manager_extra_args~}
    %{~endif}
    secret:
      create: false
      name: ${kubernetes_secret.cloud_config.0.metadata.0.name}
    EOT
  ]

  depends_on = [
    helm_release.cilium_cni,
  ]
}

resource "helm_release" "cinder_csi" {
  count = var.cinder_csi ? 1 : 0

  repository = "https://kubernetes.github.io/cloud-provider-openstack"
  chart      = "openstack-cinder-csi"
  name       = "cinder-csi"
  namespace  = "kube-system"
  version    = local.cinder_csi_version
  values = [var.cinder_csi_values, <<-EOT
    secret:
      enabled: true
      create: false
      name: ${kubernetes_secret.cloud_config.0.metadata.0.name}
    EOT
  ]

  depends_on = [
    helm_release.cloud_controller_manager
  ]
}
