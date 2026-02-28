#!/bin/bash

# 1. Update pacman mirror source list
function pacman_mirror(){
  echo y | pacman -Sy rsync
  echo y | pacman -Sy reflector
  reflector --verbose --threads 16 --score 128 -f 8 --sort rate --completion-percent 100 --age 3 --delay 0.25 --protocol https --ipv4 --save /etc/pacman.d/mirrorlist
}

# 2. Install Apps
function base_app() {
  # 1. Install filesystem tools
  echo y | pacman -Sy dosfstools exfatprogs xfsprogs
  #echo y | pacman -Sy iwd wireless-regdb # optional, wireless
  # 2. Install hardware tools
  echo y | pacman -Sy htop lm_sensors fastfetch parted
  # 3. Install file tools
  echo y | pacman -Sy rsync vim tree 
  # 4. Install shell
  echo y | pacman -Sy zsh zsh-syntax-highlighting zsh-autosuggestions zsh-completions starship
  # 5. Install firewall
  echo y | pacman -Sy nftables 
  (echo y;echo y) | pacman -Sy iptables-nft
  # 6. Install OS management tools
  echo y | pacman -Sy cronie openssh 
  # 7. Enbale app systemctl service
  systemctl enable cronie nftables sshd
}

# 3. Config app
function base_config() {
  cd $(dirname $0)
  cp ../ssh/sshd_config /etc/ssh/sshd_config || exit 0
  mkdir -p /etc/zsh && cp ../zsh/zshrc /etc/zshrc || exit 0
  cp -r ../nftables/nftables.d ../nftables/nftables.conf  /etc/ || exit 0
  mkdir -p /etc/iwd && cp ../iwd/main.conf /etc/iwd/ || exit 0
  usermod -s /usr/bin/zsh root || exit 0
}

main() {
	  pacman_mirror
	  base_app
	  base_config
}

main $1
