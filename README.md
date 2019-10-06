# provisioner

Provisioner is a bundle ansible praybooks. It allows to quickly configure linux systems.

Supported Linux Distributions
-----------------------------

-   **CentOS/RHEL** 7

#### Usage

    # Update packages and reboot
    yum update && reboot

    # Install ansible and download playbooks 
    yum install ansible git && \
    git clone https://github.com/zimmnik/provisioner.git

    # Choose playbook and edit variables
    cd provisioner/centos7 && vi run.yml

    # Run playbook
    ansible-playbook run.yml
