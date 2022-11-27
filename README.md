# provisioner

Provisioner is an ansible playbook that allow to quickly configure Gnome DE on Fedora system.

Supported distributions
-----------------------------
-   **Fedora** 36
-   **AlmaLinux** 9

## Quick Start
To deploy the system you can use :

### 1) BareMetal + Kickstart + Ansible
#### Usage:

Anaconda stage: [use kickstart file] (https://anaconda-installer.readthedocs.io/en/latest/boot-options.html#inst-ks)
```raw
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/f36.cfg
or
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/al9.cfg
```
System stage:
```ShellSession
# Set root password
passwd

# Add sudo user and set password
useradd --groups wheel --create-home username && passwd username

# Update packages and reboot
yum -y update && reboot

# WARNING! Don't use tty1 console, use tty4, because playbook will start systemd's graphical.target
# login as sudo user
logout

# Install dependencies
sudo yum -y install git

# Clone playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/ansible

# Install Ansible
python3 -m venv --upgrade-deps .py-env && source .py-env/bin/activate
pip3 install ansible-lint psutil

# Install playbook requirements
ansible-galaxy install -r requirements.yml

# Run playbook with desired hostname
ansible-playbook -i hosts -K -e "hostname=somename" run.yml
```
### 2) Libvirt + Vagrant

#### Requirements
- **git v2.31.1+**
- **libvirt v7+**
- **vagrant v2.2.16+**
- **vagrant-libvirt v0.4.1+**
- **4GB RAM for guest**

#### Usage:
```ShellSession
# Install playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/

# Deploy
time vagrant up --color [alma]

# Open GUI window
virt-manager --connect qemu:///system --show-domain-console [fedora|alma]
```
