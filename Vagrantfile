Vagrant.configure("2") do |config|
  config.vm.box = "fedora/36-cloud-base"
  #config.vm.box_url = "https://mirror.yandex.ru/fedora/linux/releases/34/Cloud/x86_64/images/Fedora-Cloud-Base-Vagrant-34-1.2.x86_64.vagrant-libvirt.box"
  #config.vm.box_url = "https://mirror.yandex.ru/fedora/linux/releases/test/36_Beta/Cloud/x86_64/images/Fedora-Cloud-Base-Vagrant-36_Beta-1.4.x86_64.vagrant-libvirt.box"
 
  config.vm.provider :libvirt do |lv|
    lv.qemu_use_session = false
    lv.title = 'fedora36'
    lv.cpus = 4
    lv.memory = 4096
    lv.video_type = 'qxl'
    lv.graphics_type = 'spice'
  end

  config.vm.provision "shell", inline: <<-SHELL
    #sed -i 's%http://download.example/pub/fedora/linux/%http://ftp.lip6.fr/ftp/pub/linux/distributions/fedora/%g' $(grep -ril 'baseurl' /etc/yum.repos.d/) && \

    sed -i 's%http://download.example/pub/fedora/linux/releases/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/fedora.redhat.com/linux/development/%g' /etc/yum.repos.d/fedora.repo
    sed -i 's%http://download.example/pub/fedora/linux/releases/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/fedora.redhat.com/linux/development/%g' /etc/yum.repos.d/fedora-modular.repo

    sed -i 's%http://download.example/pub/fedora/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/fedora.redhat.com/%g' /etc/yum.repos.d/fedora-updates.repo
    sed -i 's%http://download.example/pub/fedora/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/fedora.redhat.com/%g' /etc/yum.repos.d/fedora-updates-modular.repo
    sed -i 's%http://download.example/pub/fedora/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/fedora.redhat.com/%g' /etc/yum.repos.d/fedora-updates-testing.repo
    sed -i 's%http://download.example/pub/fedora/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/fedora.redhat.com/%g' /etc/yum.repos.d/fedora-updates-testing-modular.repo

    sed -i '/fedora-cisco-openh264-$releasever/i \#baseurl=http://codecs.fedoraproject.org/openh264/$releasever/$basearch/os/' /etc/yum.repos.d/fedora-cisco-openh264.repo

    sed -i 's/#baseurl/baseurl/g' $(grep -ril 'baseurl' /etc/yum.repos.d/) && \
    sed -i 's/metalink/#metalink/g' $(grep -ril 'metalink' /etc/yum.repos.d/) && \
    echo -e 'deltarpm=false\nzchunk=false\nproxy=http://192.168.4.253:3128' | tee -a /etc/dnf/dnf.conf

    yum -y install http://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
    sed -i 's%http://download1.rpmfusion.org/free/fedora/releases/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/rpmfusion.org/free/fedora/development/%g' /etc/yum.repos.d/rpmfusion-free.repo
    sed -i 's%http://download1.rpmfusion.org/free/fedora/updates/testing/%http://ftp-stud.hs-esslingen.de/pub/Mirrors/rpmfusion.org/free/fedora/updates/testing/%g' /etc/yum.repos.d/rpmfusion-free-updates-testing.repo
    sed -i 's/#baseurl/baseurl/g' $(grep -ril 'baseurl' /etc/yum.repos.d/) && \
    sed -i 's/metalink/#metalink/g' $(grep -ril 'metalink' /etc/yum.repos.d/) && \

    time yum makecache
    yum repolist -v | egrep "baseurl|id"

    yum -y install git
  SHELL

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
