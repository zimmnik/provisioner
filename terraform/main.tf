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

resource "libvirt_volume" "fedora_base_img" {
  name   = "Fedora-Cloud-Base-37-1.7.x86_64.qcow2"
  source = "https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.qcow2"
  #lifecycle {
  #  prevent_destroy = true
  #}
}

resource "libvirt_volume" "system_disk" {
  name           = "provisioner_fedora.qcow2"
  base_volume_id = libvirt_volume.fedora_base_img.id
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
}

resource "libvirt_domain" "demo" {
  name      = "demo"
  running   = true

  vcpu      = 4
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
    volume_id = libvirt_volume.system_disk.id
  }
  network_interface {
    network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id
}
