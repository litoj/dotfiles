#!/usr/bin/bash

swaymsg -t get_outputs | grep HEADLESS &>/dev/null || swaymsg create_output
adb reverse tcp:5900 tcp:5900
# 2260x1080@24Hz to exclude my phone's 80px notch
# swaymsg output HEADLESS-1 mode 2340x1080@24Hz enable
swaymsg output HEADLESS-1 mode 2560x1600@24Hz enable
adb shell am start -n com.gaurav.avnc/.StartupActivity &
pgrep -f wayvnc &>/dev/null || {
	wayvnc -s seat0 -o 'HEADLESS-1' -r -f 60
	swaymsg output HEADLESS-1 disable
}
