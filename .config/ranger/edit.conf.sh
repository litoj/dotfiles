# config for ../../bin/xdg-open
toOpus() {
	for f in "$@"; do
		[[ $f =~ \.(flac|m4a|mp3|wav)$ ]] || continue
		# -t $(ffprobe "$f" -show_entries format=duration -v quiet -of csv="p=0" | awk '{print $1-2}') \
		ffmpeg -v quiet -i "$f" -map 0:a -map_metadata -1 \
			"${f%.*}.opus" && rm "$f"
	done
}
try @toOpus .flac .m4a .mp3 .wav
stripMeta() {
	for f in "$@"; do nosongmeta "$f" "/tmp/$f" && rm "$f" && mv "/tmp/$f" "$f"; done
}
try @stripMeta .mp4 .opus
try @mp4tomkv .srt
try @blockbench .json
try @engrampa .jar
try @gimp .png .jpg .jpeg .xcf
try @inkscape .svg
# try @"kdenlive & dragon-drop -x -a" .mkv
BLOCKING=1
editDir() {
	# doesn't work if directories are inside the given one
	CWD=$PWD
	cd "$1"
	f=(*)
	if [[ $f =~ \.(jpg|heif|jpeg)$ ]]; then
		# alternative: 
		# fd -e jpg -e heif -x bash -c 'x="{}"
		# file "$x" | grep datetime && mv "$x" "${x%/*}/$(file "$x" |
		#   sed -En "s/.*datetime=(....):(..):(..) (..):(..):(..).*/\1_\2_\3_\4\5\6/p").${x//*.}"'
		# uses perl-image-exiftool package
		exiftool -d '%Y_%m_%d_%H%M%S.%%e' '-FileName<DateTimeOriginal' .
		cd "$CWD"
	elif [[ $f =~ \.(mp3|m4a|flac)$ ]]; then
		toOpus "${f[@]}"
		cd "$CWD"
	else
		cd "$CWD"
		xterm ranger "$@"
	fi
}
EXPLORER=@editDir
. ~/.config/open.conf.sh
