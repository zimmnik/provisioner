#!/bin/bash

#set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

#-----------------------------------------------------------------------------------------
# PROXY SETUP
# shellcheck disable=SC2016
PRX="http_proxy=http://192.168.122.1:3128"

sed -i '/fedora-cisco-openh264-$releasever/i \#baseurl=http://codecs.fedoraproject.org/openh264/$releasever/$basearch/os/' /etc/yum.repos.d/fedora-cisco-openh264.repo

while read -r filename; do 
  sed -i 's%http://download.example/pub/fedora/%http://fedora.mirrorservice.org/fedora/%g' "$filename"
  sed -i 's/#baseurl/baseurl/g' "$filename"
done < <(grep -ril 'baseurl' /etc/yum.repos.d/)

while read -r filename; do 
  sed -i 's/metalink/#metalink/g' "$filename"
done < <(grep -ril 'metalink' /etc/yum.repos.d/)

echo -e 'deltarpm=false\nzchunk=false' | tee -a /etc/dnf/dnf.conf

export "${PRX}"
echo "${PRX}" > /etc/environment
echo "export ${PRX}" > /etc/profile.d/http_proxy.sh

yum -y install "http://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"

while read -r filename; do 
  sed -i 's/#baseurl/baseurl/g' "$filename"
done < <(grep -ril 'baseurl' /etc/yum.repos.d/)

while read -r filename; do 
  sed -i 's/metalink/#metalink/g' "$filename"
done < <(grep -ril 'metalink' /etc/yum.repos.d/)

time yum -q makecache
yum repolist -v | grep -E "baseurl|id"

#-----------------------------------------------------------------------------------------
# PACKAGES

yum -y install git
