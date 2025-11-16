# provisioner

Provisioner is an ansible playbook that allow to quickly configure Gnome DE on RHEL-like systems.

Supported distributions
-----------------------------
-   **Fedora** 43
-   **OracleLinux** 10.0

## Bare metal usage

Anaconda stage: [use kickstart file] (https://anaconda-installer.readthedocs.io/en/latest/boot-options.html#inst-ks)
```raw
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/[fedora,oracle].cfg
```
System stage:
```ShellSession
passwd
useradd --groups wheel --create-home someusername && passwd someusername

# logout and login as sudo user
# WARNING! Don't use tty1 console, use tty4 instead, because playbook will start systemd's graphical.target
logout

sudo yum -y install git
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/ansible

grep 'PRETTY_NAME="Oracle Linux Server 10.0"' /etc/os-release && sudo dnf -y install oracle-epel-release-el10
sudo dnf --assumeyes --quiet install git python3.13
python3.13 -m venv --upgrade-deps .venv && source .venv/bin/activate
pip install --requirement pip_requirements.txt

export ANSIBLE_CONFIG=ansible.cfg
ansible-galaxy install --role-file galaxy_requirements.yml
ansible-playbook deploy.yml --ask-become-pass --extra-vars "hostname=somename" [--tags basic]
```

### Development
#### Requirements
- **git v2.40**
- **python v3.13**
- **vagrant-libvirt v0.7**
- **4GB RAM free for guest**

```ShellSession
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/vagrant
vagrant up --no-destroy-on-error [fedora|oracle]
