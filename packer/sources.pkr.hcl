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
  #FYI https://github.com/thomasklein94/packer-plugin-libvirt/issues/40
  network_address_source = "lease"
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
