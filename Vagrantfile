# -*- mode: ruby -*- # vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "fedora/34-cloud-base"
  config.vm.box_url = "https://mirror.yandex.ru/fedora/linux/releases/34/Cloud/x86_64/images/Fedora-Cloud-Base-Vagrant-34-1.2.x86_64.vagrant-virtualbox.box"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "provisioned_vm"
    vb.linked_clone = true
    vb.memory = 4096
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
  end
  
  config.vagrant.plugins = ["vagrant-reload"]
  #config.vagrant.plugins = ["vagrant-reload", "vagrant-vbguest"]
  #config.vbguest.installer_options = { allow_kernel_upgrade: false }
  config.vm.provision "shell", inline: "yum -y -q update"
  config.vm.provision :reload
    
  config.vm.provision "shell", inline: "yum -y -q install git"
  config.vm.provision :ansible_local do |ansible|
    #ansible.verbose = "vvvv"
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "ansible/run.yml"
    ansible.config_file = "ansible/ansible.cfg"
    ansible.galaxy_role_file = "ansible/requirements.yml"
    ansible.galaxy_roles_path = "/etc/ansible/roles"
    ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
  end
end
