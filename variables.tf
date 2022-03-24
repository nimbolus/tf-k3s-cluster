variable "cluster_name" {
  default = "example"
}

variable "cluster_availability_zone" {
  default = "nova"
}

variable "cluster_size" {
  default = 1
}

variable "cluster_servers" {
  default = 1
}

variable "cluster_image_name" {
  default = "ubuntu-20.04"
}

variable "cluster_image_id" {
  default = null
}

variable "cluster_image_scsi_bus" {
  default = false
}

variable "cluster_server_flavor_name" {
  default = "m1.medium"
}

variable "cluster_agent_flavor_name" {
  default = "m1.medium"
}

variable "cluster_server_ephemeral_volume" {
  default = false
}

variable "cluster_agent_ephemeral_volume" {
  default = false
}

variable "cluster_volume_type" {
  default = "__DEFAULT__"
}

variable "cluster_server_volume_size" {
  default = 10
}

variable "cluster_agent_volume_size" {
  default = 0
}

variable "cluster_key_pair" {
  type    = string
  default = null
}

variable "cluster_instance_stop_before_destroy" {
  default = true
}

variable "cluster_servers_server_group_policy" {
  default = "soft-anti-affinity"
}

variable "cluster_agents_server_group_policy" {
  default = "soft-anti-affinity"
}

variable "cluster_floating_ip_pool" {
  default = null
}

variable "cluster_server1_floating_ip" {
  default = true
}

variable "cluster_servers_floating_ip" {
  default = false
}

variable "cluster_agents_floating_ip" {
  default = false
}

variable "cluster_network_id" {
  type = string
}

variable "cluster_subnet_id" {
  type = string
}

variable "cluster_enable_ipv6" {
  default = false
}

variable "cluster_allow_remote_prefix_v6" {
  default = "::/0"
}

variable "cluster_k3s_args" {
  default = []
}

variable "cluster_k3s_server_args" {
  default = []
}

variable "cluster_k3s_agent_args" {
  default = []
}

variable "cluster_k3s_version" {
  default = null
}

variable "cluster_k3s_channel" {
  default = "stable"
}

variable "cluster_instance_properties" {
  description = "additional metadata properties for instances"
  default     = {}
}

variable "cluster_init" {
  default = true
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
