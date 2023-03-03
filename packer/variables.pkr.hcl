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
