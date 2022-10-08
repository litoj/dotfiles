#!/usr/bin/env bash

for f in "$@"; do
	case ${f##*.} in
		zip | jar | 7z | zst | gz | rar) setsid engrampa "$f" 2> /dev/null & ;;
		png | jpg | xcf) setsid gimp "$f" 2> /dev/null &;;
		svg) setsid inkscape "$f" 2> /dev/null & ;;
		m4a | mp3 | mp4 | mkv)
			setsid kdenlive 2> /dev/null &
			dragon-drop -x -a "$@"
			exit 0
			;;
		*) [[ -d $f ]] && { pcmanfm "$f" 2> /dev/null & } || nvim "$@" && exit 0;;
	esac
done
