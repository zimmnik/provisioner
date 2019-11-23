# provisioner

Provisioner is a bundle ansible playbooks. It allows to quickly configure linux systems.

Supported Linux Distributions
-----------------------------

-   **CentOS** 7 (Beta)
-   **CentOS** 8

#### Kickstart installation (CentOS 7 only, see [bugreport](https://bugzilla.redhat.com/show_bug.cgi?id=1712776))

    ks=https://gitlab.com/zimmnik/provisioner/raw/master/kickstart/custom.cfg

#### Usage on installed system

    # Update packages and reboot
    yum -y update && reboot
    
    # Fix warnigins and errors 
    journalctl -b0
    ...

    # Install ansible and playbooks
    yum -y install epel-release && \
    yum -y install ansible git && \
    git clone https://gitlab.com/zimmnik/provisioner.git

    # Edit variables
    cd provisioner && vi centos8/run.yml

    # Run playbook
    ansible-playbook --tags="all,gnome_de" centos8/run.yml
    
    # Setup user password
    passwd ...
    
    # Start gui
    systemctl isolate graphical.target
