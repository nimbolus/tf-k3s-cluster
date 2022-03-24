variable "node_pool_name" {
  type = string
}

variable "node_pool" {
  type = object({
    size                  = number
    availability_zone     = string
    network_id            = string
    subnet_id             = string
    image_name            = string
    image_id              = string
    image_scsi_bus        = bool
    flavor_name           = string
    ephemeral_data_volume = bool
    data_volume_type      = string
    data_volume_size      = number
    server_group_policy   = string
    floating_ip           = bool
    k3s_args              = list(string)
    k3s_version           = string
    k3s_channel           = string
    instance_properties   = map(string)
  })
}

variable "cluster_token" {
  type = string
}

variable "cluster_k3s_agent_args" {
  type = list(string)
}

variable "cluster_instance_properties" {
  type = map(string)
}

variable "k3s_url" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}
