+++
date = "2025-02-02T16:30:48Z"
title = 'Building Customized OS Images on Hetzner Cloud With Packer'
+++

I have had a server running my IRC client [irssi](https://irssi.org/) for almost 20 years. During recent years, the server has been the smallest and cheapest possible VPS from providers like Hetzner Cloud and Scaleway. Usually, I have provisioned the VM instance either manually or with Terraform, but after that, the rest of the configuration has been manual.

I really like immutable and repeatable infrastructure, and I wanted that also for this tiny VM. I've used Packer in some of my earlier projects and found it easy and straightforward to use. For this project, I wanted to use Ansible as the provisioner, because I had a couple of ready-made roles from earlier testing to configure base system, `sshd`, etc.

I also wanted the OS image to be as minimal as possible without additional services I wouldn't need. For this VM, I wanted to use Ubuntu, but my choice for the infrastructure provider, Hetzner Cloud, didn't have a ready-made image for [minimal variant](https://cloud-images.ubuntu.com/minimal/releases) of 24.04 LTS (codename Noble). I googled a bit and found out that it's possible to boot the VM to rescue mode, which is a minimal live Linux environment. From there, it's possible to download an OS image from the web and then flash it to disk, overwriting the original VM image. I used Ubuntu, but I assume that the same method works other distros too.

## Flashing Custom Image to Disk in Rescue Mode

VM can be booted to rescue mode from Hetzner Cloud management UI, but Hetzner Cloud [Packer integration](https://developer.hashicorp.com/packer/integrations/hetznercloud/hcloud) also supports it. The following presents my Packer definition `ubuntu_base.pkr.hcl` in two parts and explains them.

```hcl
packer {
  required_plugins {
    hcloud = {
      version = "~> 1"
      source  = "github.com/hetznercloud/hcloud"
    }
  }
}

variable "HCLOUD_TOKEN" {
  type      = string
  sensitive = true
  default   = env("HCLOUD_TOKEN")
}

locals {
  image_filename                 = "ubuntu-24.04-minimal-cloudimg-amd64.img"
  ubuntu_minimal_release_version = "release-20250114"
  image_sha256sum                = "4a14990ec5562d0d87501568831ce6f3c8dc32e328ac43c136aabc1cbacdf340"
  current_timestamp              = "${formatdate("YYYY-MM-DD-hhmm", timestamp())}Z"
  snapshot_name                  = "ubuntu-minimal-${local.current_timestamp}"
}
```

The first part defines that the Hetzner cloud plugin is used, reads the Hetzner Cloud API token from the `HCLOUD_TOKEN` environment variable, and then defines some local variables used in the build block.

```hcl
source "hcloud" "ubuntu" {
  token         = var.HCLOUD_TOKEN
  image         = "ubuntu-24.04"
  location      = "hel1"
  server_type   = "cx22"
  ssh_username  = "root"
  rescue        = "linux64"
  snapshot_name = local.snapshot_name
  snapshot_labels = {
    "ubuntu_release_version" = local.ubuntu_minimal_release_version
    "creation_timestamp"     = local.current_timestamp
    "type"                   = "ubuntu_minimal"
    "name"                   = local.snapshot_name
  }
}

build {
  sources = ["source.hcloud.ubuntu"]

  provisioner "shell" {
    inline = [
      "curl https://cloud-images.ubuntu.com/minimal/releases/noble/${local.ubuntu_minimal_release_version}/${local.image_filename} -O",
      "echo ${local.image_sha256sum} ${local.image_filename} | sha256sum -c -",
      "qemu-img convert -f qcow2 -O raw ${local.image_filename} ubuntu-24.04.raw",
      "dd if=ubuntu-24.04.raw of=/dev/sda bs=4M status=progress",
      "sync"
    ]
  }
}
```

The second part defines which kind of builder instance is used, in which Hetzner datacenter, and that the instance is booted to rescue mode (`rescue = "linux64"`). The used image does not matter because it will get overwritten. I also set some labels for the created VM snapshot, as these help to find in the management UI.

The gist of this post comes in the `build` block. Using inline shell provisioner, first the Ubuntu minimal image is downloaded with `curl`, and it's checksum is verified against the one checked from the Ubuntu website (for example, for this release from [here](https://cloud-images.ubuntu.com/minimal/releases/noble/release-20250114/SHA256SUMS)). Then, the image is converted from qcow2 format to raw format, because qcow2 format can't be flashed to disk directly using `dd`. Finally, the image is flashed to disk and pending write operations are flushed to disk.

After that, Hetzner Cloud snapshots the builder VM and the build is finished. This snapshot can be then used as base image for another Packer build or provisioned as a VM, for example, using Terraform. I use it as a base for another Packer build which uses Ansible to install and configure irssi and other services used in the VM. Then, I use Terraform to provision the final snapshot as a VM.
