#!/bin/bash

SELF_FILE=$(cd -P $(dirname $0);pwd)/$(basename $0)
DEV_UUID="0eb9c74a-36a1-4a4f-aeb4-d95e861dcdf2"
DEV=$(blkid|grep $DEV_UUID |awk -F":" '{print $1}')
MAPPING=cold
MAPPING_DEV=/dev/mapper/${MAPPING}
MOUNT_DIR=/up/cold
PASSWD="Bak=>@next4"

function close_mapping() {
  umount $MAPPING_DEV || echo "umount $MAPPING_DEV error"
  cryptsetup close $MAPPING_DEV || echo "cryptsetup close $MAPPING_DEV error"
}

function reformat_disk() {
  close_mapping
  # Encrypt, erase all data on device
  (echo $PASSWD;echo $PASSWD)|cryptsetup luksFormat --type luks2 --sector-size=512 $DEV
  echo $PASSWD|cryptsetup open --type luks2 $DEV $MAPPING
  # Part mapping device
  parted -sa optimal $MAPPING_DEV mklabel gpt
  partprobe
  mkfs.xfs -f -i size=512 -l size=512m -d agcount=8 $MAPPING_DEV
  NEW_DEV_UUID=$(blkid|grep $DEV|awk '{print $2}'|awk -F '=' '{print $2}')
  sed -i "s/^DEV_UUID=.*/DEV_UUID=${NEW_DEV_UUID}/" $SELF_FILE
}

function update_pass() {
  echo "Set new passphrase:"
  read -r NEW_PASS
  if [[ $PASSWD == ""  ]];then
    echo "Passphrase is set: ${NEW_PASS}"
  else
    echo $PASSWD | cryptsetup open --type luks2 $DEV $MAPPING
    (echo $PASSWD;echo $NEW_PASS;echo $NEW_PASS) | cryptsetup luksAddKey --type luks2 $DEV
    echo $PASSWD|cryptsetup luksRemoveKey --type luks2 $DEV
  fi
  sed -i "s/^PASSWD=.*/PASSWD=${NEW_PASS}/" $SELF_FILE
}

function mount_mapping() {
  echo $PASSWD | cryptsetup open --type luks2 $DEV $MAPPING
  ls -lR $MAPPING_DEV
  mkdir -p $MOUNT_DIR
  mount $MAPPING_DEV $MOUNT_DIR -t xfs
}

function init_crypt(){
  if [[ $DEV == "" ]];then
    echo "Error: Need set DEV uuid from 'blkid' and exit";exit 0
  fi
  if [[ $PASSWD == ""  ]];then
    update_pass;init_crypt
  fi
  if [[ $MAPPING == "" ]];then
    echo "Set mapping name:"
    read -r MAPPING
    sed -i "s/^MAPPING=.*/MAPPING=${MAPPING}/" $SELF_FILE
    init_crypt
  fi
  if [[ $MOUNT_DIR == ""  ]];then
    echo "Set mapping mount dir "
    read -r  MOUNT_DIR
    sed -i "s/^MOUNT_DIR=.*/MOUNT_DIR=${MOUNT_DIR}/" $SELF_FILE
    init_crypt
  fi
}

init_crypt
if [[ ${1} == "reformat" ]];then
	echo "Info: cryptsetup reformat disk ${DEV}"
	reformat_disk
elif [[ ${1} == "passwd" ]];then
	echo "Info: update cryptsetup $MAPPING password"
	update_pass
elif [[ ${1} == "mount" ]];then
	echo "Info: mount $MAPPING_DEV on $MOUNT_DIR"
	mount_mapping
elif [[ ${1} == "close" ]];then
	echo "Info: close cryptsetup mapper $MAPPING_DEV"
	close_mapping
else
	echo "Info: do nothing, need one arg [reformat|passwd|mount|close]"
	exit 0
fi

