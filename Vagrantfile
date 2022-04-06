Vagrant.configure("2") do |config|
  config.vm.box = "fedora/34-cloud-base"
  config.vm.box_url = "https://mirror.yandex.ru/fedora/linux/releases/34/Cloud/x86_64/images/Fedora-Cloud-Base-Vagrant-34-1.2.x86_64.vagrant-libvirt.box"
 
  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 4096
    libvirt.cpus = 4
    libvirt.qemu_use_session = false
  end
 
  config.vagrant.plugins = ["vagrant-reload"]
    
  config.vm.provision "shell", inline: <<-SHELL
    sed -i '/fedora-cisco-openh264-$releasever/i \#baseurl=http://codecs.fedoraproject.org/openh264/$releasever/$basearch/os/' /etc/yum.repos.d/fedora-cisco-openh264.repo && \
    sed -i 's%http://download.example/pub/fedora/%http://ftp.halifax.rwth-aachen.de/fedora/%g' $(grep -ril 'baseurl' /etc/yum.repos.d/) && \
    sed -i 's/#baseurl/baseurl/g' $(grep -ril 'baseurl' /etc/yum.repos.d/) && \
    sed -i 's/metalink/#metalink/g' $(grep -ril 'metalink' /etc/yum.repos.d/) && \
    echo -e 'deltarpm=false\nzchunk=false\nproxy=http://192.168.121.1:3128' | tee -a /etc/dnf/dnf.conf
    yum -y update
  SHELL

  config.vm.provision "shell", inline: "yum -y -q install git"
  config.vm.provision :reload

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
