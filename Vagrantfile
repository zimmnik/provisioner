# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.configure("2") do |config|
  config.vm.box = "fedora/33-cloud-base"

  #config.vagrant.plugins = "vagrant-vbguest"
  #config.vm.synced_folder ".", "/vagrant", create: true, type: "virtualbox"  
  config.vm.provider "virtualbox" do |vb|
    vb.name = "provisioned_vm"
    vb.linked_clone = true
    vb.memory = 4096
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
  end

  #config.vm.provision "shell", inline: <<-SHELL
  #  echo "excludepkgs=kernel* fedora-release*" >> /etc/dnf/dnf.conf
  #  yum -y -q update
  #SHELL
  #config.vm.provision :reload
  #
  ##config.vm.network "public_network"
  ##config.vm.provision "shell", inline: <<-SHELL
  ##  nmcli connection modify "System eth1" ipv4.route-metric 99
  ##  nmcli device reapply eth1
  ##SHELL
  # 
  #config.vm.provision "shell", inline: "yum -y -q install git"
  #config.vm.provision :ansible_local do |ansible|
  #  #ansible.verbose = "vvvv"
  #  ansible.compatibility_mode = "2.0"
  #  ansible.playbook = "ansible/run.yml"
  #  ansible.config_file = "ansible/ansible.cfg"
  #  ansible.galaxy_role_file = "ansible/requirements.yml"
  #  ansible.galaxy_roles_path = "/etc/ansible/roles"
  #  ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
  #end

  ##config.vm.provision "shell", path: "vagrant/deploy.sh", env: {"USER" => "vagrant"}
  #config.vm.provision "shell", inline: "systemctl isolate graphical"
  ##config.vm.provision :reload
end
