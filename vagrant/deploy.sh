#!/bin/bash
set -eux

# vbox display setup
sudo -u "$USER" dbus-launch dconf dump /
