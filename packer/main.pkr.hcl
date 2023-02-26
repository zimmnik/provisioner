#https://github.com/AlmaLinux/cloud-images
#https://github.com/thomasklein94/packer-plugin-libvirt/blob/87c172762d9e47e74e70a49fd5b030638a5599a6/example/cloud-init.pkr.hcl
#https://cloudinit.readthedocs.io/en/latest/reference/modules.html#set-passwords

data "sshkey" "install" {}

source "libvirt" "provisioner-fedora" {
  libvirt_uri = "qemu:///system"
  domain_name = "packer-provisioner-fedora"
  vcpu        = "4"
  cpu_mode    = "host-passthrough"
  memory      = "4096"
  chipset     = "q35"
  loader_path = "/usr/share/edk2/ovmf/OVMF_CODE.fd"
  #FYI https://github.com/thomasklein94/packer-plugin-libvirt/issues/40
  network_address_source = "lease"
  communicator {
    communicator         = "ssh"
    ssh_username         = "fedora"
    ssh_private_key_file = data.sshkey.install.private_key_path
  }
  network_interface {
    alias = "communicator"
    type  = "managed"
  }
  volume {
    name = "packer-provisioner-cloudinit-${uuidv4()}.iso"
    pool = "default"
    source {
      type = "cloud-init"
      #FYI cloud-init schema --config-file cloud_init.cfg 
      meta_data = format("#cloud-config\n%s", jsonencode({
        "instance-id" = "packer-provisioner"
      }))
      #user_data = file("${path.root}/cloud_init.cfg")
      user_data = format("#cloud-config\n%s", jsonencode({
        ssh_pwauth = "false"
        ssh_authorized_keys = [
          data.sshkey.install.public_key
        ]
      }))
    }
    target_dev = "sdb"
    bus        = "sata"
  }
  graphics {
    type = "vnc"
  }
}

locals {
  new_uuid  = uuidv4()
  manifest  = fileexists("${path.cwd}/packer-manifest.json") ? jsondecode(file("${path.cwd}/packer-manifest.json")) : null
  last_uuid = try(local.manifest.builds[0].custom_data.last_uuid, "")
}

build {
  name = "stage1"
  source "libvirt.provisioner-fedora" {
    volume {
      alias = "artifact"
      name  = "packer-provisioner-fedora-external-${local.new_uuid}.qcow2"
      pool  = "default"
      source {
        type     = "external"
        urls     = ["https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.qcow2"]
        checksum = "b5b9bec91eee65489a5745f6ee620573b23337cbb1eb4501ce200b157a01f3a0"
      }
      format     = "qcow2"
      target_dev = "sda"
      bus        = "virtio"
    }
  }
  #provisioner "breakpoint" {}
  #provisioner "shell" {
  #  inline           = ["sudo yum -y update"]
  #  valid_exit_codes = ["0", "1"]
  #}
  post-processor "manifest" {
    custom_data = {
      last_uuid = "${local.new_uuid}"
    }
  }
}

build {
  name = "stage2"
  source "libvirt.provisioner-fedora" {
    volume {
      alias = "artifact"
      name  = "packer-provisioner-fedora-backing-store-${local.last_uuid}.qcow2"
      pool  = "default"
      source {
        type   = "backing-store"
        pool   = "default"
        volume = "packer-provisioner-fedora-external-${local.last_uuid}.qcow2"
      }
      capacity   = "16G"
      format     = "qcow2"
      target_dev = "sda"
      bus        = "virtio"
    }
  }
  #provisioner "breakpoint" {}
  #provisioner "ansible" {
  #  #playbook_file = "${path.root}/playbook.yml"
  #  playbook_file = "${path.root}/../ansible/run.yml"
  #  galaxy_file   = "${path.root}/../ansible/galaxy_requirements.yml"
  #  user          = "fedora"
  #  use_proxy     = false
  #}
  post-processor "manifest" {
    custom_data = {
      last_uuid = "${local.last_uuid}"
    }
  }
}

build {
  name = "stage3"
  source "libvirt.provisioner-fedora" {
    volume {
      alias = "artifact"
      name  = "packer-provisioner-fedora-cloning-${local.last_uuid}.qcow2"
      pool  = "default"
      source {
        type   = "cloning"
        pool   = "default"
        volume = "packer-provisioner-fedora-backing-store-${local.last_uuid}.qcow2"
      }
      format     = "qcow2"
      target_dev = "sda"
      bus        = "virtio"
    }
  }
  #provisioner "breakpoint" {}
  post-processor "shell-local" {
    inline = [
      "virsh vol-delete packer-provisioner-fedora-external-${local.last_uuid}.qcow2 --pool default",
      "virsh vol-delete packer-provisioner-fedora-backing-store-${local.last_uuid}.qcow2 --pool default"
    ]
  }
}
