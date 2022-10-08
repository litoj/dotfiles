#!/usr/bin/env bash

case "$1" in
	button/lid)
		case "$3" in
			close)
				[[ $(acpi) == *D* ]] && a=1
				[[ -f /tmp/lidsleep ]] && b=1
				((a == b)) &&
					XAUTHORITY=/home/kepis/.local/share/sx/xauthority DISPLAY=:1 xset dpms force off ||
					systemctl suspend
				;;
		esac
		;;
esac
