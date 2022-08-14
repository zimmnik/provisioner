Vagrant.configure("2") do |config|

  config.vm.define "f36", autostart: true, primary: true do |f36|
    f36.vm.box = "fedora/36-cloud-base"
    f36.vm.provider :libvirt do |lv|
      lv.title = 'provisioner_f36'
    end
  end

  config.vm.define "ol9", autostart: false do |ol9|
    ol9.vm.box = "oraclelinux/9-btrfs"
    ol9.vm.box_url = "https://oracle.github.io/vagrant-projects/boxes/oraclelinux/9-btrfs.json"
    ol9.vm.provider :libvirt do |lv|
      lv.title = 'provisioner_ol9'
    end
  end
 
  config.vm.provider :libvirt do |lv|
    lv.qemu_use_session = false
    lv.cpus = 4
    lv.memory = 4096
    lv.video_type = 'virtio'
    lv.graphics_type = 'spice'
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  #config.vm.provision "shell", path: "proxy_setup.sh"
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
