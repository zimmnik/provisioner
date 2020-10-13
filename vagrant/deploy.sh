#!/bin/bash
set -eux

# displays
cp -fv /vagrant/vagrant/files/monitors.xml "/home/${USER}/.config/"
chown -v "${USER}:${USER}" "/home/${USER}/.config/monitors.xml"
sudo -u "$USER" dbus-launch dconf load / < /vagrant/vagrant/files/dconf/dconf-vbox-power.ini

# full russian localization
#sed -i 's/$/:ru_RU:ru_RU.UTF-8/' /etc/rpm/macros.image-language-conf
#yum -y reinstall dnf glibc-common
#yum -y install langpacks-ru

# user
sed -i -e "/^Wayland/a AutomaticLoginEnable=True\nAutomaticLogin=${USER}" /etc/gdm/custom.conf

# filemanager
#setcap -r /usr/bin/gnome-shell

## windowmanager
#yum -y install gnome-shell-extension-workspace-indicator
#sudo -u "$USER" dbus-launch gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
#curl -LSs https://extensions.gnome.org/extension-data/unitehardpixel.eu.v41.shell-extension.zip -o /var/cache/unite.zip
#sudo -u "$USER" dbus-launch gnome-extensions install /var/cache/unite.zip
#sudo -u "$USER" dbus-launch gnome-extensions enable unite@hardpixel.eu
#rm -v /var/cache/unite.zip
#sudo -u "$USER" dbus-launch dconf load / < /vagrant/vagrant/files/dconf/dconf-windows.ini
#
## firefox
#yum -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
#yum -y install firefox ffmpeg libva libva-utils
#
#sudo -i -u "$USER" firefox --headless -CreateProfile default
#cd "/home/${USER}/.mozilla/firefox/"
#PROFILE=$(find . -maxdepth 1 -type d -name "*.default" -printf '%f\n')
#cp -fv /vagrant/vagrant/files/firefox/profiles.ini .
#chown -Rv "${USER}:${USER}" profiles.ini
#sed -i "s/__ID__/${PROFILE%%.*}/" profiles.ini
#
#cp -fv /vagrant/vagrant/files/firefox/user.js "$PROFILE"
#
#mkdir -v "${PROFILE}/extensions" && cd "${PROFILE}/extensions"
#curl -Ls "https://addons.mozilla.org/firefox/downloads/file/3561208/" -o simple-translate@sienori.xpi
#curl -Ls "https://addons.mozilla.org/firefox/downloads/file/3579401/" -o uBlock0@raymondhill.net.xpi
#curl -Ls "https://addons.mozilla.org/firefox/downloads/file/3518684/" -o {d7742d87-e61d-4b78-b8a1-b469842139fa}.xpi # vimium-ff
#chown -Rv "${USER}:${USER}" ../extensions && cd ~
#
## chromium
#yum -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
#time yum -y install chromium-freeworld
#
## keepassxc
#yum -y install keepassxc kpcli
#mkdir -p "/home/${USER}/.config/keepassxc"
#cp -fv /vagrant/vagrant/files/keepassxc/keepassxc.ini "/home/${USER}/.config/keepassxc"
#chown -Rv "${USER}:${USER}" "/home/${USER}/.config/keepassxc"
#chmod -Rv og-rwx "/home/${USER}/.config/keepassxc"
#
#mkdir -p "/home/${USER}/.config/autostart"
#cp -fv /usr/share/applications/org.keepassxc.KeePassXC.desktop "/home/${USER}/.config/autostart/"
#chown -Rv "${USER}:${USER}" "/home/${USER}/.config/autostart"
#
## freerdp
#yum -y install freerdp
#cat /vagrant/vagrant/files/freerdp.bashrc >> "/home/${USER}/.bashrc"
#
## gvim
#yum -y install gvim
#cat /vagrant/vagrant/files/gvim.settings >> "/home/${USER}/.vimrc"
#chown -v "${USER}:${USER}" "/home/${USER}/.vimrc"
#
## libreoffice
#yum -y install libreoffice-writer libreoffice-calc
#
## tmux
#cp /vagrant/vagrant/files/tmux.conf "/home/${USER}/.tmux.conf"
#chown -v "${USER}:${USER}" "/home/${USER}/.tmux.conf"
#
## ssh agent
#mkdir -v "/home/${USER}/.ssh/"
#cp /vagrant/vagrant/files/ssh-agent/rc "/home/${USER}/.ssh/rc"
#chown -Rv "${USER}:${USER}" "/home/${USER}/.ssh"
#chmod -Rv og-rwx "/home/${USER}/.ssh"
#cat /vagrant/vagrant/files/ssh-agent/agent.tmux >> "/home/${USER}/.tmux.conf"
#chown -v "${USER}:${USER}" "/home/${USER}/.tmux.conf"
#
## reload GUI
##systemctl isolate graphical
