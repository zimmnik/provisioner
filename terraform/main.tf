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
  name             = "provisioner-terraform-oracle.qcow2"
  pool             = "default"
  base_volume_name = "provisioner-packer-oracle9.v9.qcow2"
}

data "template_file" "meta_data" {
  template = file("${path.module}/cloud_init_meta.cfg")
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init_user.cfg")
}

resource "libvirt_cloudinit_disk" "main" {
  name      = "provisioner-terraform-oracle-cloudinit.iso"
  meta_data = data.template_file.meta_data.rendered
  user_data = jsonencode(data.template_file.user_data.rendered)
}

resource "libvirt_domain" "main" {
  name    = "provisioner-terraform-oracle"
  running = true

  #firmware = "/usr/share/edk2/ovmf/OVMF_CODE.fd"
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
  console {
    type        = "pty"
    target_port = "0"
    source_path = "/dev/pts/0"
  }

  cloudinit = libvirt_cloudinit_disk.main.id
}
