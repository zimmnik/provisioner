# provisioner

Provisioner is a bundle ansible praybooks. It allows to quickly configure linux systems.

Supported Linux Distributions
-----------------------------

-   **CentOS/RHEL** 7

#### Usage

    # Update packages and reboot
    yum -y update && reboot

    # Install ansible and download playbooks 
    yum -y install ansible git && \
    git clone https://github.com/zimmnik/provisioner.git

    # Edit variables
    cd provisioner && vi centos7/run.yml

    # Run playbook
    ansible-playbook centos7/run.yml
