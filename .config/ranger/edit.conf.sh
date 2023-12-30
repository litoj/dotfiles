# config for ../../bin/xdg-open
# functions must be prefixed with @ otherwise they're run as external commands (and not found)
# -t $(ffprobe "$f" -show_entries format=duration -v quiet -of csv="p=0" | awk '{print $1-2}') \
try @gimp .png .jpg .jpeg .xcf
try @engrampa .jar
try @inkscape .svg
try @blockbench .json
BLOCKING=1
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
		# alternative:
		# fd -e jpg -e heif -x bash -c 'x="{}"
		# file "$x" | grep datetime && mv "$x" "${x%/*}/$(file "$x" |
		#   sed -En "s/.*datetime=(....):(..):(..) (..):(..):(..).*/\1_\2_\3_\4\5\6/p").${x//*.}"'
		cd "$CWD"
	elif [[ $f =~ \.(mp3|m4a|flac)$ ]]; then
		toOpus "${f[@]}"
		cd "$CWD"
	else
		cd "$CWD"
		pcmanfm "$@"
	fi
}
EXPLORER=@editDir
