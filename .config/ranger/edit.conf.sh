# config for ../../bin/xdg-open
# functions must be prefixed with @ otherwise they're run as terminal commands (and not found)
TERM_BLOCKING=1
try 'tar -xvf' .bz2 .gz .tgz .xz .zst
try '7z x' .7z .tar .rar .zip
try @blockbench .json
try @engrampa .jar

try @inkscape +image/*svg
export RUSTICL_ENABLE=radeonsi
editImage() {
	if swaymsg "[app_id=gimp] focus" &>/dev/null; then
		run @gimp
	else
		run @darktable
	fi
}
try @editImage .jpg
try @darktable .RAF .JPG .raf .dng
try @gimp +image

# try @"kdenlive & dragon-drop -x -a" .mkv

try 'mom cut' .MOV ^VID_.*
try 'mom edit --delete-src --pick-all' +audio .flac .opus .m4a .mp3 .wav .wma
try 'mom subtitles --delete-src' .srt .mp4

try 'jupyter nbconvert --to script' .ipynb

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
		which pcmanfm &>/dev/null && run @pcmanfm || run ranger
	fi
}
EXPLORER=@editDir
FALLBACK=
