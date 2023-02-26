packer {
  required_plugins {
    #FYI https://developer.hashicorp.com/packer/plugins/builders/libvirt
    libvirt = {
      version = ">= 0.4.2"
      source  = "github.com/thomasklein94/libvirt"
    }
    #FYI https://developer.hashicorp.com/packer/plugins/datasources/sshkey
    sshkey = {
      version = ">= 1.0.1"
      source  = "github.com/ivoronin/sshkey"
    }
  }
}
