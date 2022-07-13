variable "cluster_servers" {
  default = 1
}

variable "cluster_server1_floating_ip" {
  default = true
}

variable "cluster_servers_floating_ip" {
  default = false
}

variable "cluster_server_taint" {
  default = false
}

variable "cluster_k3s_server_args" {
  default = []
}

variable "cluster_init" {
  default = true
}

variable "cluster_agent_node_pools" {
  default     = {}
  description = "k3s agent node pools"
  type = map(object({
    size                  = number
    availability_zone     = optional(string)
    network_id            = optional(string)
    subnet_id             = optional(string)
    image_name            = optional(string)
    image_id              = optional(string)
    image_scsi_bus        = optional(bool)
    flavor_name           = optional(string)
    ephemeral_data_volume = optional(bool)
    data_volume_type      = optional(string)
    data_volume_size      = optional(number)
    server_group_policy   = optional(string)
    floating_ip           = optional(bool)
    k3s_args              = optional(list(string))
    k3s_version           = optional(string)
    k3s_channel           = optional(string)
    k3s_install_url       = optional(string)
    instance_properties   = optional(map(string))
    allowed_address_cidrs = optional(map(string))
  }))
}

variable "k3s_master_load_balancer" {
  description = "create Octavia load balancer for k3s master nodes"
  default     = false
}

variable "openstack_auth_url" {
  description = "Keystone auth url used for CCM and Cinder CSI"
  default     = null
}

variable "openstack_region" {
  description = "Keystone region used for CCM and Cinder CSI"
  default     = null
}

variable "openstack_application_credential_id" {
  description = "Keystone app credential id used for CCM and Cinder CSI"
  default     = null
}

variable "openstack_application_credential_secret" {
  description = "Keystone app credential secret used for CCM and Cinder CSI"
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes major and minor version for CCM and CSI compatibiliy matrix (supported versions: v1.20-v1.23)"
  default     = "v1.22"
}

variable "cloud_controller_manager" {
  description = "deploy OpenStack CCM"
  default     = false
}

variable "cloud_controller_manager_version" {
  description = "CCM Helm chart version"
  default     = null
}

variable "cloud_controller_manager_lb_monitor" {
  description = "add monitors to octavia load balancers created by CCM"
  default     = true
}

variable "cinder_csi" {
  description = "deploy OpenStack Cinder CSI driver"
  default     = false
}

variable "cinder_csi_version" {
  description = "Cinder CSI Helm chart version"
  default     = null
}

variable "cinder_csi_values" {
  description = "additional Helm values for Cinder CSI chart"
  default     = <<-EOT
    storageClass:
      enabled: true
      delete:
        isDefault: true
    EOT
}

variable "cilium_cni" {
  description = "deploy Cilium CNI instead of k3s' default CNI driver"
  default     = false
}

variable "cilium_cni_version" {
  description = "Cilium CNI Helm chart version"
  default     = "1.11.2"
}

variable "cilium_cni_values" {
  description = "additional Helm values for Cilium CNI chart"
  default     = ""
}

variable "system_upgrade_controller" {
  description = "deploy system-upgrade-controller for unattended k3s and OpenStack instance upgrades"
  default     = false
}

variable "system_upgrade_controller_version" {
  description = "system-upgrade-controller Helm chart version"
  default     = "0.1.0"
}

variable "system_upgrade_k3s_plan" {
  description = "enable system-upgrade-controller plan for unattended k3s updates"
  default     = true
}

variable "system_upgrade_k3s_plan_channel" {
  description = "upgrade channel unattended k3s updates (supported channels: stable, latest)"
  default     = "stable"
}
