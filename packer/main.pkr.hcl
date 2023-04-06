packer {
  required_plugins {
    #FYI https://developer.hashicorp.com/packer/plugins/builders/libvirt
    libvirt = {
      version = ">= 0.4.3"
      source  = "github.com/thomasklein94/libvirt"
    }
    #FYI https://developer.hashicorp.com/packer/plugins/datasources/sshkey
    sshkey = {
      version = ">= 1.0.1"
      source  = "github.com/ivoronin/sshkey"
    }
  }
}

data "sshkey" "install" {}

variable "uuid" {
  type    = string
  default = ""
}

variable "os" {
  type = string
  #default = "fedora37"
}

variable "user" {
  type = string
  #default = "fedora"
}
variable "img-link" {
  type = list(string)
  #default = ["https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.qcow2"]
}
variable "img-checksum" {
  type = string
  #default = "b5b9bec91eee65489a5745f6ee620573b23337cbb1eb4501ce200b157a01f3a0"
}

locals {
  name_prefix = "provisioner-packer-${var.os}"
  domain_name = "${local.name_prefix}-${uuidv4()}"
}

#WAREHOUSE
#new_uuid  = uuidv4()
#manifest  = fileexists("${path.cwd}/packer-manifest.json") ? jsondecode(file("${path.cwd}/packer-manifest.json")) : null
#last_uuid = try(local.manifest.builds[0].custom_data.last_uuid, "")
#https://github.com/AlmaLinux/cloud-images
#https://github.com/thomasklein94/packer-plugin-libvirt/blob/87c172762d9e47e74e70a49fd5b030638a5599a6/example/cloud-init.pkr.hcl
#https://cloudinit.readthedocs.io/en/latest/reference/modules.html#set-passwords

source "libvirt" "main" {
  libvirt_uri = "qemu:///system"
  domain_name = "${local.domain_name}"
  vcpu        = "4"
  cpu_mode    = "host-passthrough"
  memory      = "4096"
  chipset     = "q35"
  #loader_path = "/usr/share/edk2/ovmf/OVMF_CODE.fd"

  network_address_source = "agent"
  communicator {
    communicator         = "ssh"
    ssh_username         = "${var.user}"
    ssh_private_key_file = data.sshkey.install.private_key_path
  }
  network_interface {
    alias = "communicator"
    type  = "managed"
  }
  volume {
    name = "${local.name_prefix}.cloudinit${var.uuid}.iso"
    pool = "default"
    source {
      type = "cloud-init"
      #FYI cloud-init schema --config-file cloud_init.cfg 
      meta_data = format("#cloud-config\n%s", jsonencode({
        "instance-id" = "${local.name_prefix}"
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

build {
  name = "stage1"
  source "libvirt.main" {
    volume {
      alias = "artifact"
      name  = "${local.name_prefix}.stage1${var.uuid}.qcow2"
      pool  = "default"
      source {
        type     = "external"
        urls     = "${var.img-link}"
        checksum = "${var.img-checksum}"
      }
      format     = "qcow2"
      target_dev = "sda"
      bus        = "virtio"
    }
  }
  #provisioner "breakpoint" {}
}

build {
  name = "stage2"
  source "libvirt.main" {
    volume {
      alias = "artifact"
      name  = "${local.name_prefix}.stage2${var.uuid}.qcow2"
      pool  = "default"
      source {
        type   = "backing-store"
        pool   = "default"
        volume = "${local.name_prefix}.stage1${var.uuid}.qcow2"
      }
      capacity   = "37GB"
      format     = "qcow2"
      target_dev = "sda"
      bus        = "virtio"
    }
  }
  #provisioner "breakpoint" {}
  provisioner "shell" {
    inline           = ["sudo yum -y update"]
    valid_exit_codes = ["0", "1"]
  }
}

build {
  name = "stage3"
  source "libvirt.main" {
    volume {
      alias = "artifact"
      name  = "${local.name_prefix}${var.uuid}.qcow2"
      pool  = "default"
      source {
        type   = "cloning"
        pool   = "default"
        volume = "${local.name_prefix}.stage2${var.uuid}.qcow2"
      }
      format     = "qcow2"
      target_dev = "sda"
      bus        = "virtio"
    }
  }
  provisioner "ansible" {
    user             = "${var.user}"
    playbook_file    = "${path.root}/../ansible/run.yml"
    galaxy_file      = "${path.root}/../ansible/galaxy_requirements.yml"
    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False"]
    use_proxy        = false
  }
  #provisioner "breakpoint" {}
  provisioner "shell" {
    inline           = [
      "sudo yum -y install xterm-resize",
      "sudo grubby --update-kernel=ALL --args='console=ttyS0'",
      "sudo yum clean all",
      "rm -v ~/.ssh/authorized_keys"
    ]
  }
  post-processor "shell-local" {
    inline = [
      "virsh vol-delete ${local.name_prefix}.stage2${var.uuid}.qcow2 --pool default",
      "virsh vol-delete ${local.name_prefix}.stage1${var.uuid}.qcow2 --pool default"
    ]
  }
}

#WAREHOUSE
#post-processor "manifest" {
#  custom_data = {
#    last_uuid = "${local.new_uuid}" }
#}
#post-processor "shell-local" {
#  inline = ["cat ${path.cwd}/packer-manifest.json"]
#}

#virsh net-start default                             
#virsh net-dhcp-leases default
#ssh -i ~/.cache/packer/ssh_private_key_packer_rsa.pem -o "StrictHostKeyChecking=no" cloud-user@192.168.122.30
 
#virsh vol-list --pool default 
#virsh vol-delete packer-provisioner-fedora.qcow2 --pool default
 
#python3 -m venv --upgrade-deps .venv && source .venv/bin/activate
#pip3 install molecule ansible-core ansible-lint psutil molecule-vagrant
 
#export CHECKPOINT_DISABLE=1
#export PACKER_LOG=1
 
#export PKR_VAR_uuid=".$(uuidgen)"; set -e; for I in 1 2 3; do packer build -only="stage$I.libvirt.main" -force -on-error=ask -var-file="packer/oracle.pkrvars.hcl" packer; done
