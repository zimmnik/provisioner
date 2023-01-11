# provisioner

Provisioner is an ansible playbook that allow to quickly configure Gnome DE on RHEL-like systems.

Supported distributions
-----------------------------
-   **Fedora** 37
-   **AlmaLinux** 9
-   **OracleLinux** 9

## Deploy

Anaconda stage: [use kickstart file] (https://anaconda-installer.readthedocs.io/en/latest/boot-options.html#inst-ks) 
```raw
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/f37.cfg
or
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/al9.cfg
or
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/ol9.cfg
```
System stage:
```ShellSession
# Set root password
passwd

# Add sudo user and set password
useradd --groups wheel --create-home username && passwd username

# WARNING! Don't use tty1 console, use tty4, because playbook will start systemd's graphical.target
# login as sudo user
logout

# Install dependencies
sudo yum -y install git

# Clone playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/ansible

# Install Ansible
python3 -m venv --upgrade-deps .py-env && source .py-env/bin/activate
pip3 install ansible-core psutil

# Install playbook requirements
ansible-galaxy install -r galaxy_requirements.yml

# Run playbook with desired hostname
ansible-playbook -i hosts -K -e "hostname=somename" run.yml
```
### Development
#### Requirements
- **git**
- **python3**
- **vagrant-libvirt**
- **4GB RAM free for guest**

#### Usage:
```ShellSession
# Install playbooks
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/ansible

# Prepare virtual python environment
python3 -m venv --upgrade-deps .py-env && source .py-env/bin/activate
pip3 install molecule ansible-core ansible-lint psutil molecule-vagrant

# Deploy
molecule drivers -f plain
tree /home/zorg/.cache/molecule/
time molecule test --destroy never -p alma

# Open GUI window
virt-manager --connect qemu:///system --show-domain-console [fedora|alma|oracle]
```
