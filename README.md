# provisioner

Provisioner is a bundle ansible praybooks. It allows to quickly configure linux systems.

Supported Linux Distributions
-----------------------------

-   **CentOS/RHEL** 7

#### Usage
    # Update packates
    sudo yum update

    # Install dependencies 
    sudo yum install ansible git

    # Download playbooks
    git clone https://github.com/zimmnik/provisioner.git

    # Choose playbook
    cd provisioner/centos7

    # Edit variables
    vim run.yml

    # Run playbook
    ansible-playbook run.yml
