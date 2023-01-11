Vagrant.configure("2") do |config|

  config.vm.define "alma", autostart: false do |alma|
    alma.vm.box = "almalinux/9"
    alma.vm.provider :libvirt do |lv|
      lv.title = 'alma'
    end
  end

  config.vm.define "fedora", autostart: true, primary: true do |fedora|
    fedora.vm.box = "fedora/37-cloud-base"
    fedora.vm.provider :libvirt do |lv|
      lv.title = 'fedora'
    end
  end

  config.vm.define "oracle", autostart: false do |oracle|
    oracle.vm.box = "oraclelinux/9-btrfs"
    oracle.vm.box_url = "https://oracle.github.io/vagrant-projects/boxes/oraclelinux/9-btrfs.json"
    oracle.vm.provider :libvirt do |lv|
      lv.title = 'oracle'
    end
  end
 
  config.vm.provider :libvirt do |lv|
    lv.cpus = 4
    lv.memory = 4096
    lv.video_type = 'virtio'
    lv.graphics_type = 'spice'
    lv.default_prefix = ''
    lv.qemu_use_session = false
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.provision "shell", inline: "yum -y -q install git"
  config.vm.provision :ansible_local do |ansible|
    #ansible.verbose = "vvvv"
    ansible.compatibility_mode = "2.0"
    ansible.raw_arguments = "--diff"
    ansible.playbook = "ansible/run.yml"
#    ansible.config_file = "ansible/ansible.cfg"
    ansible.galaxy_role_file = "ansible/galaxy_requirements.yml"
    ansible.galaxy_command = "ansible-galaxy install --role-file %{role_file}"
  end
end
