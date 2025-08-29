#!/usr/bin/bash
# $1=delay in seconds, $2=minimum battery percentage to not hibernate
for ((i = ${1:-60}; i > 0; i--)); do
	notify-send -u critical -t 984 -h int:value:$((i * 3)) \
		-h string:synchronous:hibernate "Hibernating in ${i}s" 'Plug the system in.'
	sleep 1
done

bat=(/sys/class/power_supply/BAT*/uevent)
bat=${bat[${BAT:-0}]}
if [[ $(<"${bat%uevent}status") != Charging && $(<"${bat%uevent}capacity") -lt ${2:-30} ]]; then
	{ [[ $(swapon --show=NAME) ]] || sudo swapon /swapfile; } &&
		systemctl hibernate && sleep 60 &&
		sudo swapoff /swapfile && swaymsg output eDP-1 power on
fi
