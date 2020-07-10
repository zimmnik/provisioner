#!/bin/bash
set -eux

# displays
cp -fv /vagrant/vagrant/files/monitors.xml "/home/${USER}/.config/"
chown -v "${USER}:${USER}" "/home/${USER}/.config/monitors.xml"
sudo -u "$USER" dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
sudo -u "$USER" dbus-launch dconf load / < /vagrant/vagrant/files/dconf/dconf-power.ini
sed -i '/^#Wayland/ s/#//g' /etc/gdm/custom.conf

# timedate
timedatectl set-ntp true
timedatectl set-timezone Europe/Moscow

# locale
#sed -i 's/$/:ru_RU:ru_RU.UTF-8/' /etc/rpm/macros.image-language-conf
#yum -yq reinstall dnf glibc-common
#yum -yq install langpacks-ru
yum -yq install glibc-langpack-ru
localectl set-locale LANG=ru_RU.UTF-8 LC_MESSAGES="en_US.UTF-8"
sudo -u "$USER" dbus-launch dconf load / < /vagrant/vagrant/files/dconf/dconf-locale.ini

# user
echo "${USER}:${USER}" | chpasswd
sed -i -e "/^Wayland/a AutomaticLoginEnable=True\nAutomaticLogin=${USER}" /etc/gdm/custom.conf

# terminal
curl -LSs https://extensions.gnome.org/extension-data/quake-mode%40repsac-by.github.com.v2.shell-extension.zip -o /var/cache/quake-mode.zip
sudo -u "$USER" dbus-launch gnome-extensions install /var/cache/quake-mode.zip
rm -v /var/cache/quake-mode.zip
sudo -u "$USER" dbus-launch gnome-extensions enable quake-mode@repsac-by.github.com
sudo -u "$USER" dbus-launch dconf load / < /vagrant/vagrant/files/dconf/dconf-terminal.ini
cat /vagrant/vagrant/files/bash.bashrc >> "/home/${USER}/.bashrc"

# filemanager
yum -yq install gnome-shell-extension-desktop-icons xdg-user-dirs-gtk
setcap -r /usr/bin/gnome-shell
sudo -u "$USER" dbus-launch gnome-extensions enable desktop-icons@csoriano
sudo -u "$USER" dbus-launch dconf load / < /vagrant/vagrant/files/dconf/dconf-filemanager.ini

# windowmanager
yum -yq install gnome-shell-extension-workspace-indicator
sudo -u "$USER" dbus-launch gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
curl -LSs https://extensions.gnome.org/extension-data/unitehardpixel.eu.v41.shell-extension.zip -o /var/cache/unite.zip
sudo -u "$USER" dbus-launch gnome-extensions install /var/cache/unite.zip
sudo -u "$USER" dbus-launch gnome-extensions enable unite@hardpixel.eu
rm -v /var/cache/unite.zip
sudo -u "$USER" dbus-launch dconf load / < /vagrant/vagrant/files/dconf/dconf-windows.ini

# firefox
yum -yq install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
yum -yq install firefox ffmpeg libva libva-utils

sudo -i -u "$USER" firefox --headless -CreateProfile default
cd "/home/${USER}/.mozilla/firefox/"
PROFILE=$(find . -maxdepth 1 -type d -name "*.default" -printf '%f\n')
cp -fv /vagrant/vagrant/files/firefox/profiles.ini .
chown -Rv "${USER}:${USER}" profiles.ini
sed -i "s/__ID__/${PROFILE%%.*}/" profiles.ini

cp -fv /vagrant/vagrant/files/firefox/user.js "$PROFILE"

mkdir -v "${PROFILE}/extensions" && cd "${PROFILE}/extensions"
curl -Ls "https://addons.mozilla.org/firefox/downloads/file/3561208/" -o simple-translate@sienori.xpi
curl -Ls "https://addons.mozilla.org/firefox/downloads/file/3579401/" -o uBlock0@raymondhill.net.xpi
curl -Ls "https://addons.mozilla.org/firefox/downloads/file/3518684/" -o {d7742d87-e61d-4b78-b8a1-b469842139fa}.xpi # vimium-ff
chown -Rv "${USER}:${USER}" ../extensions && cd ~

# chromium
yum -yq install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
time yum -yq install chromium-freeworld

# keepassxc
yum -yq install keepassxc kpcli
mkdir -p "/home/${USER}/.config/keepassxc"
cp -fv /usr/share/applications/org.keepassxc.KeePassXC.desktop "/home/${USER}/.config/autostart/"
chown -Rv "${USER}:${USER}" "/home/${USER}/.config/keepassxc"
chmod -Rv og-rwx "/home/${USER}/.config/keepassxc"
sudo -u "$USER" mkdir "/home/${USER}/.config/autostart"
cp -fv /vagrant/vagrant/files/keepassxc/org.keepassxc.KeePassXC.desktop "/home/${USER}/.config/autostart"
chown -Rv "${USER}:${USER}" "/home/${USER}/.config/autostart"

# freerdp
yum -yq install freerdp
cat /vagrant/vagrant/files/freerdp.bashrc >> "/home/${USER}/.bashrc"

# gvim
yum -yq install gvim
cat /vagrant/vagrant/files/gvim.settings >> "/home/${USER}/.vimrc"
chown -v "${USER}:${USER}" "/home/${USER}/.vimrc"

# libreoffice
yum -y install libreoffice-writer libreoffice-calc

# podman
yum -y install @"Container Management" podman-docker
touch /etc/containers/nodocker
sed -i "s/iptables/firewalld/" /etc/cni/net.d/87-podman-bridge.conflist
sudo sh -c 'echo "net.ipv4.ping_group_range = 0 2000000" > /etc/sysctl.d/podman_ping.conf'

# kubectl
cp -v /vagrant/vagrant/files/kubectl/kubernetes.repo /etc/yum.repos.d/
yum -yq install kubectl bash-completion
kubectl completion bash > /etc/bash_completion.d/kubectl
cat /vagrant/vagrant/files/kubectl/kubectl.bashrc >> "/home/${USER}/.bashrc"
mkdir -p "/home/${USER}/.kube"
chown -v "${USER}:${USER}" "/home/${USER}/.kube"

# devops utilites
yum -yq install ShellCheck jq curl

# stretchly
yum -yq install https://github.com/hovancik/stretchly/releases/download/v0.21.1/stretchly-0.21.1.x86_64.rpm
mkdir -p "/home/${USER}/.config/stretchly/"
cp -frv /vagrant/vagrant/files/stretchly/config.json "/home/${USER}/.config/stretchly/"
chown -Rv "${USER}:${USER}" "/home/${USER}/.config/keepassxc"
sudo -u "$USER" mkdir "/home/${USER}/.config/autostart"
cp -fv /usr/share/applications/stretchly.desktop "/home/${USER}/.config/autostart/"
chown -Rv "${USER}:${USER}" "/home/${USER}/.config/autostart"

# skype
curl -Ls https://repo.skype.com/rpm/stable/skype-stable.repo -o /etc/yum.repos.d/skype-stable.repo
yum -yq install skypeforlinux

# telegram
yum -yq install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
yum -yq install telegram-desktop

# evolution
yum -yq install evolution evolution-pst

# tmux
cp /vagrant/vagrant/files/tmux.conf "/home/${USER}/.tmux.conf"
chown -v "${USER}:${USER}" "/home/${USER}/.tmux.conf"


# ssh agent
mkdir -v "/home/${USER}/.ssh/"
cp /vagrant/vagrant/files/ssh-agent/rc "/home/${USER}/.ssh/rc"
chown -Rv "${USER}:${USER}" "/home/${USER}/.ssh"
chmod -Rv og-rwx "/home/${USER}/.ssh"
cat /vagrant/vagrant/files/ssh-agent/agent.tmux >> "/home/${USER}/.tmux.conf"
chown -v "${USER}:${USER}" "/home/${USER}/.tmux.conf"

# reload GUI
#systemctl isolate graphical
