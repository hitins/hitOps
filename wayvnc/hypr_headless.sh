#!/bin/bash

if [[ -z $(hyprctl monitors|grep -e ^Monitor|grep Headless-VNC) ]];then
	hyprctl output create headless Headless-VNC
fi
if [[ -z $(ps -aux|grep "wayvnc -o=Headless-VNC" | grep -v grep) ]];then
	wayvnc -o=Headless-VNC -C ~/.config/wayvnc/config
fi
