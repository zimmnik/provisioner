# provisioner

Provisioner is an ansible playbook that allow to quickly configure Gnome DE on RHEL-based system.

Supported distributions
-----------------------------
-   **Fedora** 34

## Quick Start
To deploy the system you can use :

### 1) BareMetal + Kickstart + Ansible
#### Usage:

Anaconda stage: use kickstart file
```raw
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/custom.cfg
```
Pure system stage:  
WARNING! Don't use tty1 console, use tty2-4, because playbook will start systemd's graphical.target
```ShellSession
# Set root password
passwd

# Add sudo user and set password
useradd --groups wheel --create-home username && passwd username

# Update packages
yum -y update

# Install minimal gnome
yum -y install "@base-x" gnome-session-xsession control-center gnome-terminal

# Disable Wayland 

# Enable graphical target
systemctl set-default graphical.target

# Apply changes
reboot

# Login via GUI as sudo user and open Gnome Terminal

# Install dependencies
yum -y install ansible git

# Clone playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/ansible

# Install playbook requirements
ansible-galaxy install -r requirements.yml

# Run playbook with desired hostname
ansible-playbook -i hosts -K -e "hostname=host01" run.yml
```
### 2) VirtualBox + Vagrant

#### Requirements
- **Git v2.9.0+**
- **Virtualbox v5.2+**
- **Vagrant v2.2.7+**
- **4GB RAM for guest**

#### Usage:
```ShellSession
# Install playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/

# Deploy
time vagrant up --color

# Open GUI window
vboxmanage startvm provisioned_vm --type separate
```
