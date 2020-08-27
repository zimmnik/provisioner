# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.configure("2") do |config|
  config.vm.box = "fedora/32-cloud-base"

  config.vagrant.plugins = "vagrant-vbguest"
  config.vm.synced_folder ".", "/vagrant", create: true, type: "virtualbox"  
  config.vm.provider "virtualbox" do |vb|
    vb.name = "provisioned_vm"
    vb.linked_clone = true
    vb.memory = 2048
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
  end

  config.vm.network "public_network"
  config.vm.provision "shell", inline: <<-SHELL
    nmcli connection modify "System eth1" ipv4.route-metric 99
    nmcli connection down "System eth1"
    nmcli connection up "System eth1"
  SHELL

  config.vm.provision "shell", inline: <<-SHELL
    yum -y update
  SHELL
  config.vm.provision :reload
  config.vm.provision :ansible_local do |ansible|
    ansible.playbook = "ansible/run.yml"
    ansible.become = true
    ansible.tags = ["all", "gnome_de"]
  end
  #config.vm.provision "shell", path: "vagrant/deploy.sh", env: {"USER" => "demo"}
  #config.vm.provision :reload
end
