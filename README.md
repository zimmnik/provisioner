# provisioner

Provisioner is a bundle ansible playbooks that allow to quickly configure RHEL-based systems.

Supported distributions
-----------------------------

-   **CentOS** 7
-   **CentOS** 8
-   **Fedora** 31

## Quick Start

To deploy the cluster you can use :

### BareMetal + Kickstart + Ansible

#### Usage

```raw
# Kickstart option (except CentOS 8, see [bugreport](https://bugzilla.redhat.com/show_bug.cgi?id=1712776))
ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/custom.cfg
```
```ShellSession
# Update packages and reboot
yum -y update && reboot

# CentOS only 
yum -y install epel-release

# Install dependencies
yum -y install ansible git

# Clone playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner

# Edit variables
vi run.yml

# Run playbook
ansible-playbook -i hosts --tags=all,gnome_de run.yml

# Setup user password
passwd root 
passwd someusername

# Start GUI
systemctl isolate graphical
```
### VirtualBox + Vagrant

#### Requirements
- **Git v2.9.0+**
- **Virtualbox v5.2+**
- **Vagrant v2.2.7+**

#### Usage
```ShellSession
# Install playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner

# Edit variables
vi Vagrantfile
vi run.yml

# Deploy
vagrant up

# Setup user and root passwords
vagrant ssh
passwd root 
passwd someusername
exit

# Start GUI
vboxmanage startvm provisioned_vm --type separate
```
