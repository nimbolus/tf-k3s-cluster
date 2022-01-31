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

variable "cluster_image_scsi_bus" {
  default = false
}

variable "cluster_flavor_name" {
  default = "m1.medium"
}

variable "cluster_volume_type" {
  default = "__DEFAULT__"
}

variable "cluster_volume_size" {
  default = 10
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

variable "k3s_master_load_balancer" {
  default = false
}

variable "cluster_instance_properties" {
  description = "additional metadata properties for instances"
  default     = {}
}

variable "cloud_provider_controller_manager" {
  default = false
}

variable "cloud_provider_controller_manager_version" {
  default = "1.1.2"
}

variable "cloud_provider_controller_manager_lb_monitor" {
  default = true
}

variable "cloud_provider_cinder_csi" {
  default = false
}

variable "cloud_provider_cinder_csi_version" {
  default = "1.4.9"
}

variable "cloud_provider_auth_url" {
  description = ""
  default     = null
}

variable "cloud_provider_region" {
  description = ""
  default     = null
}

variable "cloud_provider_application_credential_id" {
  description = ""
  default     = null
}

variable "cloud_provider_application_credential_secret" {
  description = ""
  default     = null
}

variable "cilium_cni" {
  default = false
}

variable "cilium_cni_version" {
  default = "1.11.1"
}

variable "cilium_cni_values" {
  default = ""
}
