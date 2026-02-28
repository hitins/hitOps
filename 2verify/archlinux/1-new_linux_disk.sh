#!/bin/bash

# 1. Check disk, eg "check_disk nvme0n1"
function check_disk() {
  CHECK=$(lsblk |grep disk|awk -F" " '{print $1}'|grep -w $1)
  if [[ ! $1 ]] || [[  ! "$CHECK" == $1  ]];then
    echo -e "Error: \"$1\" is a invalid disk!" && exit 1
  fi
}

# 2. Part disk, eg: "part_linux_disk /dev/nvme0n1"
function part_linux_disk() {
  echo -e "Clear disk $1 "'type "y" to continue: ' 
  read -r CLEAR
  if [[ $CLEAR != "y" ]];then exit 0;fi
  
  # 1. Umount disk
  blkid|grep $1 |awk -F":" '{print $1}'|xargs umount 2> /dev/null
  blkid|grep $1 |awk -F":" '{print $1}'|xargs swapoff 2> /dev/null
  
  # 2. Clear disk and new disk gpt label
  parted -s ${1} mklabel gpt || exit 1
  
  # 3. Part disk, using 95% space, leave 5% space for more speed
  ## 3.1 Part boot partition, name "start", 512MiB "0% 512MiB", fat32
  BOOT_END=512MiB
  BOOT_NAME="start"
  parted -s -f ${1} "mkpart $BOOT_NAME 0% $BOOT_END"
  parted -s ${1} set 1 boot on
  PART_BOOT=$(blkid|grep ${1} |grep $BOOT_NAME |awk -F":" '{print $1}')
  mkfs.fat -F 32 $PART_BOOT
  
  ## 3.2 Part swap partition, name and label "swap", 2.5GiB "512MiB 3072MiB", swap
  SWAP_END=3072MiB
  SWAP_NAME="swap"
  parted -s ${1} "mkpart $SWAP_NAME linux-swap $BOOT_END $SWAP_END"
  PART_SWAP=$(blkid|grep ${1}|grep $SWAP_NAME |awk -F":" '{print $1}')
  mkswap -L $SWAP_NAME $PART_SWAP
  swapon $PART_SWAP
  
  ## 3.3 Part root partition, name "main", "3072MiB 95%", xfs
  ROOT_NAME="main"
  parted -s ${1} "mkpart $ROOT_NAME $SWAP_END 100%"
  PART_ROOT=$(blkid|grep ${1}|grep $ROOT_NAME |awk -F":" '{print $1}')
  mkfs.xfs -f $PART_ROOT
  
  ## 3.4 show disk partitions
  parted ${1} print |grep  -E "^ [1-9].*"

  # 4. Mount disk on /mnt for chroot
  umount -R /mnt 2> /dev/null
  mount $PART_ROOT /mnt
  mount --mkdir $PART_BOOT /mnt/boot

  echo -e "\nInfo: Disk ${1} is cleared and parted, and mounted on /mnt"
  echo -e "Info: Maybe zram is more useful than swap"
}

main() {
  timedatectl set-ntp true
  echo -e 'Choose one valid block device such as "nvme0n1" "sda":'
  read -r VDISK
  check_disk $VDISK
  part_linux_disk /dev/$VDISK
}

main
