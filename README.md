# provisioner

Provisioner is an ansible playbook that allow to quickly configure Gnome DE on RHEL-like systems.

Supported distributions
-----------------------------
-   **Fedora** 39
-   **AlmaLinux** 9
-   **OracleLinux** 9

## Bare metal usage

Anaconda stage: [use kickstart file] (https://anaconda-installer.readthedocs.io/en/latest/boot-options.html#inst-ks) 
```raw
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/[fedora,alma,oracle].cfg
```
System stage:
```ShellSession
passwd
useradd --groups wheel --create-home username && passwd username

# logout and login as sudo user
# WARNING! Don't use tty1 console, use tty4, because playbook will start systemd's graphical.target
logout

sudo yum -y install git
git clone https://github.com/zimmnik/provisioner.git && cd provisioner

python3 -m venv --upgrade-deps .venv && source .venv/bin/activate
pip install --requirement ansible/pip_requirements.txt
export ANSIBLE_CONFIG=ansible/ansible.cfg
ansible-galaxy install --role-file ansible/galaxy_requirements.yml

ansible-inventory --inventory ansible/hosts --graph --vars
ansible-playbook --inventory ansible/hosts --ask-become-pass --extra-vars "hostname=somename" ansible/deploy.yml

```
### Development
#### Requirements
- **git**
- **python3**
- **vagrant-libvirt**
- **4GB RAM free for guest**

#### molecule-vagrant way:
```ShellSession
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/ansible

python3 -m venv --upgrade-deps .venv && source .venv/bin/activate
pip3 install -r pip_requirements.txt

molecule drivers -f plain
time molecule test --destroy never -p [fedora|alma|oracle]
tree ~/.cache/molecule/

virt-manager --connect qemu:///system --show-domain-console [fedora|alma|oracle]
```
#### pure-vagrant way:
```ShellSession
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/vagrant

vagrant plugin install vagrant-reload
vagrant up --no-parallel --no-destroy-on-error [fedora|alma|oracle]
```
#### packer way:
```ShellSession
git clone https://github.com/zimmnik/provisioner.git && cd provisioner

python3 -m venv --upgrade-deps .venv && source .venv/bin/activate
pip install --requirement ansible/pip_requirements.txt
export ANSIBLE_CONFIG=ansible/ansible.cfg
ansible-galaxy install --role-file ansible/galaxy_requirements.yml

export CHECKPOINT_DISABLE=1
export PACKER_LOG=1

for I in 1 2 3; do packer build -only="stage$I.libvirt.main" -force -on-error=cleanup -var-file="packer/[fedora|alma|oracle].pkrvars.hcl" packer; if [ $? -ne 0 ]; then break; fi; done
virsh vol-list --pool default | grep provisioner

# terraform manifest isn't finished yet
```
