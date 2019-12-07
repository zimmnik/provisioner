# provisioner

Provisioner is a bundle ansible playbooks that allow to quickly configure CentOS systems.

Supported Linux Distributions
-----------------------------

-   **CentOS** 7
-   **CentOS** 8
-   **Fedora** 31

#### Kickstart installation (except CentOS 8, see [bugreport](https://bugzilla.redhat.com/show_bug.cgi?id=1712776))

    ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/custom.cfg
#### Usage on installed system

    # Update packages and reboot
    yum -y update && reboot

    # CentOS only 
    yum -y install epel-release

    # Install ansible and playbooks
    yum -y install ansible git && \
    git clone https://github.com/zimmnik/provisioner.git

    # Edit variables
    cd provisioner && vi run.yml

    # Run playbook
    ansible-playbook --tags=all,gnome_de run.yml
    
    # Setup user password
    passwd ...
    
    # Start GUI
    systemctl isolate graphical
