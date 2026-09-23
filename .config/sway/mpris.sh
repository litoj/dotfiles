#!/usr/bin/bash

# playerctl scoped to mpv - kept as an arg array so it can be invoked directly
mpv=(playerctl --player=mpv)

# Print mpv metadata formatted by $1
info() {
	"${mpv[@]}" metadata --format "$1"
}

# Path of the current file: strip the file:// URI prefix, then decode the URI.
# Literal '+' is escaped to %2b first, so urlencode -d returns it unchanged.
mpv_file() {
	info '{{xesam:url}}' | sed -e 's,file://,,' -e 's,+,%2b,g' | urlencode -d
}

# Notify with title and position, re-read every second for 3 s, so the
# progress stays in sync while the player keeps moving
mpv_notify() {
	local pos len percent oldpos
	for _ in {1..3}; do
		pos=$(info '{{position}}') len=$(info '{{mpris:length}}')
		# playerctl may emit fractions - bash arithmetic accepts integers only
		pos=${pos%%.*} len=${len%%.*}
		[[ $pos == "${oldpos}" ]] && return || oldpos=$pos
		percent=0
		((len > 0)) && percent=$((pos / (len / 100)))
		notify-send -u low -a player -h string:synchronous:player \
			-h "int:value:$percent" -t 1100 \
			"$(info '{{title}}')" \
			"$(info '\t{{duration(position)}}/{{duration(mpris:length)}}' | sed 's/^ - //')"
		sleep 1
	done
}

# Dispatcher for actions passed as the first argument
case "${1}" in
	'info') ;;
	'play_path')
		mpv_file
		exit 0
		;;
	'mpv') "${mpv[@]}" "${@:2}" ;;
	*) playerctl -a "${@}" ;;
esac
mpv_notify
