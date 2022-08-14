#!/bin/bash

#---------------------------------------------------------------------------------------------
setup_repo_el9 () {
  while read -r filename; do
    sed -i 's/baseurl=https:/baseurl=http:/g' "$filename"
  done < <(grep -ril 'baseurl' /etc/yum.repos.d/)  
}

#---------------------------------------------------------------------------------------------
setup_repo_f36 () {
  # shellcheck disable=SC2016
  sed -i '/fedora-cisco-openh264-$releasever/i \#baseurl=http://codecs.fedoraproject.org/openh264/$releasever/$basearch/os/' /etc/yum.repos.d/fedora-cisco-openh264.repo
  
  while read -r filename; do 
    #sed -i 's%http://download.example/pub/fedora/%http://fedora.mirrorservice.org/fedora/%g' "$filename"
    sed -i 's%http://download.example/pub/fedora%http://fr2.rpmfind.net/linux/fedora%g' "$filename"
    sed -i 's/#baseurl/baseurl/g' "$filename"
  done < <(grep -ril 'baseurl' /etc/yum.repos.d/)
  
  while read -r filename; do 
    sed -i 's/metalink/#metalink/g' "$filename"
  done < <(grep -ril 'metalink' /etc/yum.repos.d/)
}

#---------------------------------------------------------------------------------------------
setup_repo_main () {
  if [[ "${PLATFORM_ID}" = "platform:f36" ]]; then
    setup_repo_f36
  elif [[ "${PLATFORM_ID}" = "platform:el9" ]]; then
    setup_repo_el9
  else
    echo "Unsupported OS ${PLATFORM_ID}"
    exit 1
  fi
}

#---------------------------------------------------------------------------------------------
setup_repo_extra () {
  if [[ "${PLATFORM_ID}" = "platform:f36" ]]; then
    yum -y install distribution-gpg-keys
    yum -y install "http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    
    while read -r filename; do 
      sed -i 's%http://download1.rpmfusion.org/free/fedora%http://fr2.rpmfind.net/linux/rpmfusion/free/fedora%g' "$filename"
      sed -i 's/#baseurl/baseurl/g' "$filename"
    done < <(grep -ril 'baseurl' /etc/yum.repos.d/)
    
    while read -r filename; do 
      sed -i 's/metalink/#metalink/g' "$filename"
    done < <(grep -ril 'metalink' /etc/yum.repos.d/)
  elif [[ "${PLATFORM_ID}" = "platform:el9" ]]; then
    :
  else
    echo "Unsupported OS ${PLATFORM_ID}"
    exit 1
  fi
}

#---------------------------------------------------------------------------------------------
main () {
  #set -o xtrace
  set -o pipefail
  set -o nounset
  set -o errexit
  
  eval "$(grep PLATFORM_ID /etc/os-release)"

  setup_repo_main

  echo -e 'deltarpm=false\nzchunk=false' >> /etc/dnf/dnf.conf

  GW=$(ip r | grep default | head -1 | awk '{print $3}')
  http_proxy="http://${GW}:3128"
  export http_proxy=${http_proxy}
  echo "http_proxy=${http_proxy}" >> /etc/environment
  echo "export http_proxy=${http_proxy}" >> /etc/profile.d/http_proxy.sh

  setup_repo_extra

  time yum -q makecache
  yum repolist -v | grep -E "baseurl|id"

}
main "$@"

