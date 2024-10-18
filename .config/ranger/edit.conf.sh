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
try 'mom edit' .flac .opus .m4a .mp3 .wav .wma
try 'mom subtitles' .srt .mp4
# try @"kdenlive & dragon-drop -x -a" .mkv
editDir() {
	# doesn't work if directories are inside the given one
	CWD=$PWD
	cd "$1"
	f=(*)
	if [[ $f =~ \.(jpg|JPG|heif|jpeg)$ ]]; then
		# uses perl-image-exiftool package
		mom rename .
		cd "$CWD"
	elif [[ $f =~ \.(mp3|m4a|flac)$ ]]; then
		mom edit "${f[@]}"
		cd "$CWD"
	else
		cd "$CWD"
		which pcmanfm && pcmanfm "$@" || xterm ranger "$@" &
	fi
}
EXPLORER=@editDir
