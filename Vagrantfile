# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.configure("2") do |config|
  config.vm.box = "fedora/32-cloud-base"

  config.vm.provision "shell", inline: <<-SHELL
    yum -y update
  SHELL
  config.vm.provision :reload
  config.vm.provision :ansible_local do |ansible|
    ansible.playbook = "run.yml"
    ansible.become = true
    ansible.tags = ["all", "gnome_de"]
  end
  config.vm.provision "shell", inline: <<-SHELL
    systemctl isolate graphical
  SHELL
  
  config.vm.provider "virtualbox" do |vb|
    vb.name = "provisioned_vm"
    vb.linked_clone = true
    vb.memory = 2048
  end
end
