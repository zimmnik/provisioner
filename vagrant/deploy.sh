#!/bin/bash
set -e

# displays
cp -fv /vagrant/vagrant/files/monitors.xml /home/demo/.config/
chown -v demo:demo /home/demo/.config/monitors.xml
sudo -u demo dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
sudo -u demo dbus-launch dconf load / < /vagrant/vagrant/files/dconf-power.ini
sed -i '/^#Wayland/ s/#//g' /etc/gdm/custom.conf

# timedate
timedatectl set-ntp true
timedatectl set-timezone Europe/Moscow

# locale
#sed -i 's/$/:ru_RU:ru_RU.UTF-8/' /etc/rpm/macros.image-language-conf
#yum -y reinstall dnf glibc-common
#yum -y install langpacks-ru
yum -y install glibc-langpack-ru
localectl set-locale LANG=ru_RU.UTF-8 LC_MESSAGES="en_US.UTF-8"
sudo -u demo dbus-launch dconf load / < /vagrant/vagrant/files/dconf-locale.ini

# user
echo 'demo:demo' | chpasswd
sed -i -e '/^Wayland/a AutomaticLoginEnable=True\nAutomaticLogin=demo' /etc/gdm/custom.conf

# terminal
curl -LSs https://extensions.gnome.org/extension-data/quake-mode%40repsac-by.github.com.v2.shell-extension.zip -o /var/cache/quake-mode.zip
sudo -u demo dbus-launch gnome-extensions install /var/cache/quake-mode.zip
rm -v /var/cache/quake-mode.zip
sudo -u demo dbus-launch gnome-extensions enable quake-mode@repsac-by.github.com
sudo -u demo dbus-launch dconf load / < /vagrant/vagrant/files/dconf-terminal.ini

# windowmanager
yum -y install gnome-shell-extension-workspace-indicator
sudo -u demo dbus-launch gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
yum -y install xorg-x11-utils
curl -LSs https://extensions.gnome.org/extension-data/unitehardpixel.eu.v41.shell-extension.zip -o /var/cache/unite.zip
sudo -u demo dbus-launch gnome-extensions install /var/cache/unite.zip
sudo -u demo dbus-launch gnome-extensions enable unite@hardpixel.eu
rm -v /var/cache/unite.zip
sudo -u demo dbus-launch dconf load / < /vagrant/vagrant/files/dconf-windows.ini

# filemanager
yum -y install gnome-shell-extension-desktop-icons
setcap -r /usr/bin/gnome-shell
sudo -u demo mkdir -v /home/demo/Desktop
sudo -u demo dbus-launch gnome-extensions enable desktop-icons@csoriano
sudo -u demo dbus-launch gsettings get org.gnome.shell enabled-extensions
sudo -u demo dbus-launch dconf load / < /vagrant/vagrant/files/dconf-filemanager.ini

# debug
sudo -u demo dbus-launch gsettings get org.gnome.shell enabled-extensions
