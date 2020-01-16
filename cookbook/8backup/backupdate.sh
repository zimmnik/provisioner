@weekly 25      backup          bash -c "/usr/local/bin/backup.sh | tee >(systemd-cat -t backup)"
10 15 * * mon root bash -c "/usr/local/bin/backup.sh | tee >(systemd-cat -t backup)"

#!/bin/bash

set -e
PASS=password
DATE=$(date -I)

#---------------------------------------------------------------------------------------------
check_depencences () {
which ssh
which scp
which 7za
which par2verify
which par2create
which lvcreate
which lvremove
which yum
}

#---------------------------------------------------------------------------------------------
system_transfer () {
scp -oProxyCommand="ssh -i ../fs.key -W %h:%p user@ssh.proxy" -i ../fs.key \
latest/system-backup-$DATE.fsa someuser@ssh.storage:/stor/backup/systemname/system/latest || return $?
}

#---------------------------------------------------------------------------------------------
data_transfer () {
scp -oProxyCommand="ssh -i ../fs.key -W %h:%p user@ssh.proxy" -i ../fs.key \
latest/data-backup-$DATE.7z someuser@ssh.storage:/stor/backup/systemname/data/latest/ || return $?
}

#---------------------------------------------------------------------------------------------
run_7z () {
7za a -ssc -p$PASS latest/data-backup-$DATE.7z \
/mnt/data-snap/some_important_folder/ \
/mnt/root-snap/home/user/another_important_folder/
}

#---------------------------------------------------------------------------------------------
run_fsarchiver () {
if ! [[ -f fsarchiver-static-0.8.5.x86_64 ]]; then
  curl --silent --show-error --location --remote-name https://github.com/fdupoux/fsarchiver/releases/download/0.8.5/fsarchiver-static-0.8.5.x86_64.tar.gz
  tar --extract --file=fsarchiver-static-0.8.5.x86_64.tar.gz --strip-components 1
  rm -v fsarchiver-static-0.8.5.x86_64.tar.gz 
fi
./fsarchiver-static-0.8.5.x86_64 \
--allow-rw-mounted --zstd=19 --jobs=4 --cryptpass $PASS \
--exclude=/var/lib/containers \
--exclude=/home/user/.local/share/containers \
savefs latest/system-backup-$DATE.fsa \
/dev/disk/by-id/ata-Samsung_SSD_860_EVO_250GB_part1 \
/dev/disk/by-id/ata-Samsung_SSD_860_EVO_250GB_part2 \
/dev/systemname/root-snap
}

data_backup () {
cd /mnt/backup/data
  lvcreate -s -n root-snap -L4G /dev/systemname/root
  lvcreate -s -n data-snap -L4G /dev/systemname/data
      mkdir /mnt/root-snap /mnt/data-snap
        mount -v -o ro /dev/systemname/root-snap /mnt/root-snap
        mount -v -o ro /dev/systemname/data-snap /mnt/data-snap
          run_7z
        umount -v /mnt/root-snap
        umount -v /mnt/data-snap
      rm -r /mnt/root-snap /mnt/data-snap
  lvremove -A y -f /dev/systemname/root-snap
  lvremove -A y -f /dev/systemname/data-snap
par2create -r100 -n1 -t4 -T4 -q latest/data-backup-$DATE.7z
data_transfer
}

system_backup () {
cd /mnt/backup/system
  lvcreate -s -n root-snap -L4G /dev/systemname/root
      mkdir /mnt/root-snap
        mount -v -o ro /dev/systemname/root-snap /mnt/root-snap
          rm -rf previous/
            run_fsarchiver
        umount -v /mnt/root-snap
      rm -r /mnt/root-snap
  lvremove -A y -f /dev/systemname/root-snap
par2create -r100 -n1 -t4 -T4 -q latest/system-backup-$DATE.fsa
system_transfer	
}

rotate () {
cd /mnt/backup/
  pwd
  par2verify -q data/latest/*.7z.par2
  par2verify -q system/latest/*.fsa.par2

cd /mnt/backup/data
  pwd
  rm -v -rf previous/
  mv -v latest/ previous
  mkdir -v latest

cd /mnt/backup/system
  pwd
  rm -v -rf previous/
  mv -v latest/ previous
  mkdir -v latest

cd /mnt/backup/
pwd
ssh -Ao ProxyCommand="ssh -i fs.key -W %h:%p user@ssh.proxy" \
-i fs.key -T someuser@ssh.storage << 'EOF' || return $?
cd /stor/backup/systemname/system && pwd && \
rm -v -rf previous && mv -v latest/ previous && mkdir -v latest && \
cd /stor/backup/systemname/data && pwd && \
rm -v -rf previous && mv -v latest/ previous && mkdir -v latest
EOF
}

#---------------------------------------------------------------------------------------------
check_depencences
mount -v /dev/disk/by-id/ata-WDC_WD3200AAKX-part1 /mnt/backup
if [[ $(date +%u) -eq 1 ]]; then
	rotate
	system_backup
fi
data_backup
cd / && umount -v /mnt/backup

#-------------------------------------------------------------------------------------
if [[ $(date +%u) -eq 1 ]]; then
	#yum --assumeyes --quiet upgrade-minimal 
	yum --assumeyes --disablerepo=@kubernetes --disablerepo=@virtualbox upgrade
	sleep 60 && reboot
fi

#-------------------------------------------------------------------------------------
#trap 'cd /; umount -v EXIT'
