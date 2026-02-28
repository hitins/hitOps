#!/bin/bash

# Debian 13 trixie

# Install Fonts
#
apt -y update
## Noto CJK 汉字
apt -y install fonts-noto-cjk-extra
## Nerd Fonts
apt -y install wget unzip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip -P /root/fonts
mkdir /usr/share/fonts/truetype/source-code-pro-nerd
unzip /root/fonts/SourceCodePro.zip -d /usr/share/fonts/truetype/source-code-pro-nerd
rm -rf /root/fonts

# Install sway
#
apt -y install alacritty sway swayidle swaylock wofi waybar wayvnc
apt -y autoremove foot wmenu
