#!/usr/bin/bash

cd ~/Pictures/screen
[[ ! -f /tmp/my/nextbg ]] && cp ~/.cache/nextbg /tmp/my/nextbg
next=$(head -n 1 /tmp/my/nextbg 2> /dev/null)
if [[ $next ]]; then
	sed -i 1d /tmp/my/nextbg
else
	next=($(fd))
	printf '%s\n' "${next[@]:1}" | shuf > /tmp/my/nextbg
fi

swaybg -i "$next" -m fill &>/dev/null &
disown
