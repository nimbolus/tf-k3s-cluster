variable "cluster_name" {
  default = "example"
}

variable "cluster_key_pair" {
  type    = string
  default = null
}

variable "cluster_instance_stop_before_destroy" {
  default = true
}

variable "cluster_floating_ip_pool" {
  default = null
}

variable "cluster_enable_ipv6" {
  default = false
}

variable "cluster_allow_remote_prefix_v6" {
  default = "::/0"
}

variable "cluster_k3s_args" {
  description = "k3s args for all servers and agents"
  default     = ["--node-label", "cloud-provider=openstack"]
}

variable "cluster_node_domain" {
  description = "DNS domain for nodes , e.g. mycluster.exmaple.com"
  default     = null
}
