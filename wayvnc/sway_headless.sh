#!/bin/bash

nohup bash -c """
export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
export WAYLAND_DISPLAY=wayland-1
sway &
wayvnc -C ~/.config/wayvnc/config""" > ~/.config/wayvnc/wayvnc.log 2>&1 &