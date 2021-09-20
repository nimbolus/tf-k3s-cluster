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
  type = string
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

variable "cluster_k3s_server_exec" {
  default = ""
}
