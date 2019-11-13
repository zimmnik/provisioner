# provisioner

Provisioner is a bundle ansible praybooks. It allows to quickly configure linux systems.

Supported Linux Distributions
-----------------------------

-   **CentOS** 7
-   **CentOS** 8 (Beta)

#### Kickstart installation (CentOS 7 only, see [bugreport](https://bugzilla.redhat.com/show_bug.cgi?id=1712776))

    inst.ks=https://gitlab.com/zimmnik/provisioner/raw/master/centos7/kickstart/custom.cfg

#### Usage on installed system

    # Update packages and reboot
    yum -y update && reboot

    # Install ansible and download playbooks 
    yum -y install ansible git && \
    git clone https://github.com/zimmnik/provisioner.git

    # Edit variables
    cd provisioner && vi centos7/run.yml

    # Run playbook
    ansible-playbook centos7/run.yml
    
    # Setup user password
    passwd someusername
    
    # run gui
    systemctl isolate graphical.target
