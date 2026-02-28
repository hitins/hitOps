#!/bin/bash

function base_config() {

  # 1. Set timezone UTC+8
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

  # 2. Set locale
  echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\nzh_CN.GB18030 GB18030" > /etc/locale.gen 
  locale-gen
  echo LANG=en_US.UTF-8 > /etc/locale.conf
  echo LC_CTYPE=en_US.UTF-8 >> /etc/locale.conf
  echo LC_ALL=en_US.UTF-8 >> /etc/locale.conf
  
  # 3. Set vconsole font "sun12x22"
  echo FONT=sun12x22 > /etc/vconsole.conf

  # 4. Set hostname
  HOSTNAME=$(cat /etc/os-release|grep -ie '^id='|awk -F"=" '{print $2}') || echo 0
  echo $HOSTNAME > /etc/hostname

  # 5. Set network interface alter name disabled
  sed -i 's/^AlternativeNamesPolicy/#AlternativeNamesPolicy/' /usr/lib/systemd/network/99-default.link 

  # 6. Set resolv.conf Immutable
  cd /etc && cat resolv.conf > resolvconf.conf && rm resolv.conf && mv resolvconf.conf resolv.conf || exit0
  
  # 7. Set log
  journalctl --vacuum-size=16M # 限制日志大小 eg 16M
  journalctl --vacuum-time=3d # 限制日志保留时间 eg 1 天
  
  # 8. Disable some systemd service
  systemctl disable remote-fs.target --now
  systemctl disable systemd-resolved.service  --now
  systemctl disable systemd-networkd.service  --now
  systemctl disable remote-cryptsetup.target --now 
}

base_config
