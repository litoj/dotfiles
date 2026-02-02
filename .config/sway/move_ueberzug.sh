#!/usr/bin/bash

(($(ps -o pid= -C move_ueberzug.sh | wc -l) < 3)) || exit 0 # when scrolling through images
tree=$(swaymsg -t get_tree -p)

get_ws() {
	local ws=$(echo "$tree" | awk '$2=="workspace" {w=$3}; /pid: '$1'/ {print w;exit}')
	echo "${ws:1:-1}"
}

get_parent_win_ws() { # ranger runs inside a terminal windowa or neovim
	declare -i id=$1
	local ws
	while [[ -z $ws ]] ; do
		id=$(ps -o ppid= "$id")
		ws=$(get_ws "$id")
	done
	echo "$ws"
}

declare -i corrected=0
while read -r pid; do
	uw=$(get_ws $pid)
	[[ $uw ]] || continue
	rw=$(get_parent_win_ws $pid)
	[[ $uw == $rw ]] && continue # ignore correctly placed ueberzug windows

	((corrected += 1))
	swaymsg "[pid=$pid] move workspace $rw" &>/dev/null
done < <(ps -o pid= -C ueberzug)

((corrected)) || sleep 1 # to block at least some redundant instances when scrolling through images
