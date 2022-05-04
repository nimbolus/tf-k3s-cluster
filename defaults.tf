# Default variables for k3s server and agent nodes
# cluster_agent_node_pools attributes can overwrite these variables

variable "cluster_availability_zone" {
  type    = string
  default = "nova"
}

variable "cluster_network_id" {
  type = string
}

variable "cluster_subnet_id" {
  type = string
}

variable "cluster_image_name" {
  type    = string
  default = "ubuntu-20.04"
}

variable "cluster_image_id" {
  type    = string
  default = null
}

variable "cluster_image_scsi_bus" {
  type    = bool
  default = false
}

variable "cluster_flavor_name" {
  type    = string
  default = "m1.medium"
}

variable "cluster_ephemeral_data_volume" {
  type    = bool
  default = false
}

variable "cluster_data_volume_type" {
  type    = string
  default = "__DEFAULT__"
}

variable "cluster_data_volume_size" {
  type    = number
  default = 10
}

variable "cluster_server_group_policy" {
  type    = string
  default = "soft-anti-affinity"
}

variable "cluster_k3s_version" {
  type    = string
  default = null
}

variable "cluster_k3s_channel" {
  type    = string
  default = "stable"
}

variable "cluster_k3s_install_url" {
  type    = string
  default = "https://get.k3s.io"
}

variable "cluster_k3s_agent_args" {
  description = "k3s args for agent nodes, when not overwritten by the node pool `k3s_args` attribute"
  type        = list(string)
  default     = []
}

variable "cluster_instance_properties" {
  description = "additional metadata properties for instances"
  type        = map(string)
  default     = {}
}
