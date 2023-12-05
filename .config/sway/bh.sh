#!/usr/bin/bash

cd ~/Pictures/screen
[[ ! -f /tmp/nextbg ]] && cp ~/.cache/nextbg /tmp/nextbg
next=$(head -n 1 /tmp/nextbg 2> /dev/null)
if [[ $next ]]; then
	sed -i 1d /tmp/nextbg
else
	next=($(fd))
	printf '%s\n' "${next[@]:1}" | shuf > /tmp/nextbg
fi

swaybg -i "$next" -m fill &>/dev/null &
disown
