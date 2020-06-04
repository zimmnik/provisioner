#!/bin/bash
set -e
vboxManage controlvm provisioned_vm poweroff || true
sleep 3
vboxManage snapshot provisioned_vm restore ready
#vboxManage startvm provisioned_vm --type headless
#while ! ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .vagrant/machines/default/virtualbox/private_key -p 2222 vagrant@localhost exit; do
#  sleep 2
#done
#echo Done
