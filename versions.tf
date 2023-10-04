terraform {
  required_version = ">= 1.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.0"
    }
    k8sbootstrap = {
      source  = "nimbolus/k8sbootstrap"
      version = "~> 0.1.1"
    }
  }
}
