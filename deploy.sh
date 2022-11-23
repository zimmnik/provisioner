#!/bin/bash

set -o pipefail
set -o nounset
set -o errexit
set -o xtrace

cd /vagrant/ansible
sudo yum -y install git
python3 -m venv --upgrade-deps .py-env && source .py-env/bin/activate
pip3 install ansible psutil ansible-lint
ansible-lint
ansible-galaxy install -r requirements.yml
ansible-playbook -i hosts run.yml
