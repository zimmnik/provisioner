
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
