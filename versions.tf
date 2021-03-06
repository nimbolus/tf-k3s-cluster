terraform {
  required_version = ">= 1.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.43.0"
    }
    k8sbootstrap = {
      source  = "nimbolus/k8sbootstrap"
      version = "~> 0.1.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.13.0"
    }
  }
}
