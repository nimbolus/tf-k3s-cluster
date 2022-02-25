# terraform module - k3s cluster

Sets up a k3s cluster on top of OpenStack based on the [tf-k3s](https://github.com/nimbolus/tf-k3s) module.

For an overview of the options, checkout [variables.tf](./variables.tf)

## Enable Cinder CSI

```hcl
module "cluster"
  source = "git::https://github.com/nimbolus/tf-k3s-cluster.git"
  # ...
  cinder_csi = true
  cinder_csi_version = "1.4.9"
```
