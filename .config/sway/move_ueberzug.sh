#!/usr/bin/bash

ps -o pid= -C move_ueberzug.sh | wc -l | grep 1 &>/dev/null || exit 0 # when scrolling through images
tree=$(swaymsg -t get_tree -p)

get_ws() {
	echo "$tree" | grep -F "pid: $1" -B 5 |
		sed -nE 's/.*workspace "([0-9].*)"$/\1/p' | tail -n 1
}

while read -r pid; do
	uw=$(get_ws $pid)
	[[ $uw ]] || continue
	ranger_win=$(ps -o ppid= $(ps -o ppid= $pid)) # ranger runs inside a terminal window
	rw=$(get_ws $ranger_win)
	[[ $uw == $rw ]] && continue # ignore correctly placed ueberzug windows

	swaymsg "[pid=$pid] move workspace $rw" &>/dev/null
done < <(ps -o pid= -C ueberzug)

# sleep 3 # to block at least some redundant instances when scrolling through images
