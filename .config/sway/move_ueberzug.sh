#!/usr/bin/bash

(($(ps -o pid= -C move_ueberzug.sh | wc -l) < 3)) || exit 0 # when scrolling through images
tree=$(swaymsg -t get_tree -p)

get_ws() {
	echo "$tree" | grep -F "pid: $1" -B 5 |
		sed -nE 's/.*workspace "([0-9].*)"$/\1/p' | tail -n 1
}

get_win_id() { # ranger runs inside a terminal windowa or neovim
	declare -i id=$1 lastid
	while ((id != 1)); do
		lastid=$id
		id=$(ps -o ppid= "$lastid")
	done
	echo "$lastid"
}

declare -i corrected=0
while read -r pid; do
	uw=$(get_ws $pid)
	[[ $uw ]] || continue
	ranger_win=$(get_win_id $pid)
	rw=$(get_ws $ranger_win)
	[[ $uw == $rw ]] && continue # ignore correctly placed ueberzug windows

	((corrected+=1))
	swaymsg "[pid=$pid] move workspace $rw" &>/dev/null
done < <(ps -o pid= -C ueberzug)

((corrected)) || sleep 1 # to block at least some redundant instances when scrolling through images
