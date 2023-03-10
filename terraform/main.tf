terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
  required_version = "~> 1.3"
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "main" {
  name             = "provisioner-terraform-fedora.qcow2"
  pool             = "default"
  base_volume_name = "provisioner-packer-fedora37.v2.qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "main" {
  name      = "provisioner-terraform-fedora-cloudinit.iso"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_domain" "main" {
  name    = "provisioner-terraform-fedora"
  running = true

  vcpu = 4
  cpu {
    mode = "host-passthrough"
  }
  memory = "4096"
  video {
    type = "virtio"
  }
  graphics {
    type = "spice"
  }
  disk {
    volume_id = libvirt_volume.main.id
  }
  network_interface {
    network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.main.id
}
