# config for ../../bin/xdg-open
# functions must be prefixed with @ otherwise they're run as external commands (and not found)
{
	try @inkscape +image/*svg
	try @darktable .raf
	try @gimp +image
	try @blockbench .json
} &> /dev/null
try @engrampa .jar
BLOCKING=1
try 'tar -xvf' .bz2 .gz .tgz .xz .zst
try '7z x' .7z .tar .rar .zip
edit() {
	mom -e "$1" -e -f
}
try edit .flac
try 'mom -e' .m4a .mp3 .wav .wma
try 'mom --subtitles' .srt .mp4
try 'mom -M' .opus
# try @"kdenlive & dragon-drop -x -a" .mkv
editDir() {
	# doesn't work if directories are inside the given one
	CWD=$PWD
	cd "$1"
	f=(*)
	if [[ $f =~ \.(jpg|JPG|heif|jpeg)$ ]]; then
		# uses perl-image-exiftool package
		exiftool -d '%Y_%m_%d_%H%M%S.%%e' '-FileName<DateTimeOriginal' .
		cd "$CWD"
	elif [[ $f =~ \.(mp3|m4a|flac)$ ]]; then
		mom -e "${f[@]}"
		cd "$CWD"
	else
		cd "$CWD"
		which pcmanfm && pcmanfm "$@" || xterm ranger "$@" &
	fi
}
EXPLORER=@editDir
