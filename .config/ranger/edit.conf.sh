# config for ../../bin/xdg-open
# functions must be prefixed with @ otherwise they're run as external commands (and not found)
try @inkscape +image/*svg &>/dev/null
try @gimp +image &>/dev/null
try @blockbench .json &>/dev/null
try @engrampa .jar
BLOCKING=1
try 'tar -xvf' .bz2 .gz .tgz .xz .zst
try '7z x' .7z .tar .rar .zip
try 'mom -c' .flac .m4a .mp3 .wav .wma
try 'mom --subtitles' .srt .mp4
# try @"kdenlive & dragon-drop -x -a" .mkv
editDir() {
	# doesn't work if directories are inside the given one
	CWD=$PWD
	cd "$1"
	f=(*)
	if [[ $f =~ \.(jpg|heif|jpeg)$ ]]; then
		# uses perl-image-exiftool package
		exiftool -d '%Y_%m_%d_%H%M%S.%%e' '-FileName<DateTimeOriginal' .
		cd "$CWD"
	elif [[ $f =~ \.(mp3|m4a|flac)$ ]]; then
		mom -c "${f[@]}"
		cd "$CWD"
	else
		cd "$CWD"
		which pcmanfm && pcmanfm "$@" || xterm ranger "$@" &
	fi
}
EXPLORER=@editDir
