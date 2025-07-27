#config for ../bin/xdg-open
BROWSER=@${BROWSER#@}
TERM_BLOCKING=1
try 'mpv --no-audio-display' +audio .m3u .m4a .mp3
try '@mpv --no-terminal' +video
# try @geeqie .RAF
imgFallback() {
	BLOCKING=1
	# try @imv-dir +image
	if (($# > 1)); then
		try '@swayimg -c list.all=no' +image
	else
		try @swayimg +image
	fi || try @geeqie +image
}
try @imgFallback +image
try @engrampa .7z .bz2 .gz .rar .tar .tgz .xz .zip .zst
try @zathura .pdf
try @transmission-gtk magnet:
try @thunderbird mailto:
try @twitch youtube.com/watch youtu.be
try "$BROWSER" http: https:
try 'java -jar' .jar
try '' .AppImage # execute the file itself
try jupyter-notebook .ipynb
FALLBACK=$EDITOR
