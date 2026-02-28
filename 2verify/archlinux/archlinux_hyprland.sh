#!/bin/bash

pacman -Syu
if (lspci|grep -i vga|grep -i intel);then
	GPU_DRI=vulkan-intel
	echo y|pacman -Sy intel-media-driver
elif (lspci|grep -i vga|grep -i amd);then
	GPU_DRI=vulkan-radeon
elif (lspci|grep -i vga|grep -i nvidia);then
	GPU_DRI=vulkan-nouveau
elif (lspci|grep -i vga|grep -i virtio);then
	GPU_DRI=vulkan-virtio
fi

# all below choose 2 pipeware-jack
echo y|pacman -Sy mesa $GPU_DRI
echo y|pacman -Sy hyprland 
systemctl enable seatd.service --now
(echo 2;echo y)|pacman -Sy hypridle hyprlock hyprpaper wofi waybar
echo y|pacman -Sy alacritty ttf-sourcecodepro-nerd adobe-source-han-sans-cn-fonts 

# eg: user "hypr"
function new_hyprland_user() {
	useradd -m -G seat,input hypr
	cd $(dirname $0)
	su - hypr -c "mkdir -p ~/.config/systemd/user/" || exit 0
	cp -r ../alacritty ../hypr ../waybar /home/hypr/.config/
	cp ../hypr/hyprland-startup.service /home/hypr/.config/system/user/
	chown hypr:hypr -R /home/work/.config
	su - hypr -c "systemctl daemon-reload;systemctl --user enable hyprland-startup.service" || echo 0
}
#new_hyprland_user

# wayland VNC server: wayvnc
#echo y|pacman -Sy wayvnc 

