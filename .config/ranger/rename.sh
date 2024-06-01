#!/usr/bin/bash

if [[ $1 == *.mkv || $1 == *.mpv ]]; then
	mv "$1" "$(echo "$1" | sed 's/\./ /g;s/^\(.*\) \([0-9]\{4\}\) .* \(...\)$/\2 \1.\3/')"
else
	exiftool -d '%Y_%m_%d_%H%M%S.%%e' '-FileName<DateTimeOriginal' "$1"
fi
