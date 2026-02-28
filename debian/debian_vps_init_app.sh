#!/bin/bash

# 1. Update
apt -y update && apt -y dist-upgrade

# 2. Install App
apt -y install ca-certificates cron dhcpcd fastfetch htop openssl openssh-server rsync tree vim starship

# 3. Remove app and clean
apt -y autoremove --purge keyboard-configuration apt-utils
apt -y autoremove --purge exim4-base
apt -y autoremove --purge wpasupplicant
apt -y autoremove isc-dhcp-client isc-dhcp-common
apt -y clean all
apt -y autoremove --purge

# 3. Config
echo -e 'eval "$(starship init bash)" || echo 1' >> /root/.bashrc

# 4. Enable or Disable some systemctl service
systemctl enable dhcpcd sshd --now
systemctl disable networking --now
reboot

# Optional
#
## Podman: install and config service
#apt -y install podman
#systemctl disable networking podman-auto-update.timer podman.socket podman podman-restart --now
#
## iwd: wireless if need
#apt -y install iwd
