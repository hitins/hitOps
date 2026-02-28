#!/bin/bash

# 1. Base Install
function base_install() {
  
  # 1.1 Install "base linux-lts linux-firmware intel-ucode"
  if [[ -n  $(cat /proc/cpuinfo | grep model | grep -i intel && echo intel) ]];then
	  CPU_M=intel
  elif [[ -n  $(cat /proc/cpuinfo | grep model | grep -i amd && echo amd) ]];then
	  CPU_M=amd
  else
	  echo "Error: CPU model is neither intel nor amd !!! Stop or Update this script!"
	  exit 1
  fi
  echo y | pacstrap -K /mnt base linux-lts linux-firmware-$CPU_M linux-firmware-other $CPU_M-ucode
  [ $? -eq 0 ] || (echo 'Error: run "pacman-key --refresh-keys" and run again, or check others' && exit 0 )

  # 1.2 Generate "/etc/fstab"'
  genfstab -U /mnt > /mnt/etc/fstab

  # 1.3 Install dhcpcd for dhcp, iwd for wireless, iptables-nft for libxtables
  arch-chroot /mnt /bin/sh -c """
  (echo y;echo y) | pacman -Sy iptables-nft
  echo y | pacman -Sy dhcpcd iwd
  systemctl enable dhcpcd iwd
  """
  
  # 1.4 Change root password
  arch-chroot /mnt /bin/sh -c """
  echo 'Info: set root password:'
  passwd
  """
}

# 2. Default Boot install
function refind_boot_install() {
  arch-chroot /mnt /bin/sh -c """
  echo 'Info: install refind boot loader'
  pacman -Syu && echo y | pacman -Sy refind
  refind-install
  """
}
## Optional Boot install
function grub_boot_install() {
  arch-chroot /mnt /bin/sh -c """
  echo 'Info: install grub boot loader'
  pacman -Syu && echo y | pacman -Sy grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg
  """
}

main() {
  echo "Info: update gpg keyring"
  echo y | pacman -Sy archlinux-keyring
  
  base_install || exit 1
  
  refind_boot_install || exit 1
  
  echo -e 'Notice:\n'
  echo -e '1. *important* Delete invalid boot option from /boot/refind_linux.conf!'
  echo -e '2. *optional* Install firmware of necessary hardware can be searched by "lspci, lsusb, etc."\n'
  echo -e '3. Restart, enter new Arch Linux to continue !" 
}

main
