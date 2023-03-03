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
      name  = "${local.name_prefix}.final${var.uuid}.qcow2"
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
    inline           = ["sudo yum clean all"]
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
