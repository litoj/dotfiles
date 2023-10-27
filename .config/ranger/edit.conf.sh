# config for ../../bin/xdg-open
toopus() {
	for f in "$@"; do
		ffmpeg -i "$f" -map 0:a -map_metadata -1 "${f%.*}.opus"
		rm "$f"
	done
}
try @toopus .flac .mp3
stripmeta() {
	for f in "$@"; do nosongmeta "$f" "/tmp/$f" && rm "$f" && mv "/tmp/$f" "$f"; done
}
try @stripmeta .aac .m4a .mp3 .mp4 .ogg .opus .wav
try @mp4tomkv .srt
try @blockbench .json
try @engrampa .jar
try @gimp .png .jpg .jpeg .xcf
try @inkscape .svg
# try @"kdenlive & dragon-drop -x -a" .mkv
BLOCKING=1
renameIfCamera() {
	# doesn't work if directories are inside the given one
	CWD=$PWD
	cd "$1"
	f=(*)
	if [[ $f == *.jpg || $f == *.heif ]]; then
		fd -e jpg -e heif -x bash -c 'x="{}"
		file "$x" | grep datetime && mv "$x" "${x%/*}/$(file "$x" |
			sed -En "s/.*datetime=(....):(..):(..) (..):(..):(..).*/\1_\2_\3_\4\5\6/p").${x//*.}"'
		cd "$CWD"
	else
		cd "$CWD"
		xterm ranger "$@"
	fi
}
EXPLORER=@renameIfCamera
. ~/.config/open.conf.sh
