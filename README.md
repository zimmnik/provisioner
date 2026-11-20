# provisioner

Provisioner is an ansible playbook that allow to quickly configure Gnome DE on RHEL-like systems.

Supported distributions
-----------------------------
-   **Fedora** 45
-   **OracleLinux** 10
-   **Debian** 13

## Bare metal usage

Installer stage:
[use kickstart file] (https://anaconda-installer.readthedocs.io/en/latest/boot-options.html#inst-ks)
[or preceed file] (https://d-i.debian.org/manual/en.amd64/ch05s03.html#installer-args)
```raw
inst.ks=https://raw.githubusercontent.com/zimmnik/provisioner/master/kickstart/[fedora,oracle].cfg
or
auto=true priority=critical preseed/url=https://raw.githubusercontent.com/zimmnik/provisioner/master/preseed/debian.cfg

```
System stage:
```ShellSession
passwd
useradd --groups [wheel|sudo] --shell /bin/bash --create-home someusername && passwd someusername

# logout and login as sudo user
# WARNING! Don't use tty1 console, use tty4 instead, because playbook will start systemd's graphical.target
logout

sudo [dnf|apt] -y install git ca-certificates
git clone https://github.com/zimmnik/provisioner.git && cd provisioner/ansible

grep 'NAME="Debian GNU/Linux"' /etc/os-release && sudo apt -yy install python3-venv git
grep -Eq '^NAME="(Fedora Linux|Oracle Linux Server)"$' /etc/os-release && sudo dnf -yq install python3-libdnf git
python3 -m venv --upgrade-deps .venv && source .venv/bin/activate
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
vagrant up --no-destroy-on-error [fedora|oracle|debian]
