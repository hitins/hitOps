#!/bin/bash

# 1. Update sh
ln -sf /bin/bash /bin/sh
ln -sf /usr/bin/bash /usr/bin/sh

# 2. Set timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 3. Set locale
echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\nzh_CN.GB18030 GB18030" > /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo LC_CTYPE=en_US.UTF-8 >> /etc/locale.conf
echo LC_ALL=en_US.UTF-8 >> /etc/locale.conf

# 4. Set hostname
HOSTNAME_PRE=$(cat /etc/os-release|grep -ie '^id='|awk -F"=" '{print $2}') || HOSTNAME_PRE="Linux"
HOSTNAME=$(cat /etc/os-release|grep -ie '^VERSION_CODENAME='|awk -F"=" '{print $2}') || HOSTNAME=${HOSTNAME_PRE}
echo $HOSTNAME > /etc/hostname

# 5. Set resolv.conf Immutable
cd /etc && cat resolv.conf > resolvconf.conf && rm resolv.conf && mv resolvconf.conf resolv.conf || exit 0
echo "nameserver 1.1.1.2" > /etc/resolv.conf
echo "persistent
ipv4only
noalias
nohook resolv.conf
" > /etc/dhcpcd.conf

# 6. Set network interface alter name disabled
sed -i 's/^AlternativeNamesPolicy/#AlternativeNamesPolicy/' /usr/lib/systemd/network/99-default.link

# 7. Set log
journalctl --vacuum-size=16M # 限制日志大小 eg 16M
journalctl --vacuum-time=3d # 限制日志保留时间 eg 1 天

# 8. Set some systemd service disabled
#systemctl list-unit-files |grep dbus-org.freedesktop |xargs systemctl disable
systemctl disable apt-daily.timer apt-daily-upgrade.timer console-setup.service e2scrub_all.timer e2scrub_reap.service dpkg-db-backup.timer keyboard-setup.service remote-fs.target unattended-upgrades.service --now
