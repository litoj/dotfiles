BLOCKING=1

toCommonAudio() {
	for f in "$@"; do
		ffmpeg -hide_banner -i "$f" "${f%.*}.m4a"
	done
}
try @toCommonAudio +audio .opus .flac .wav
# extract image previews
try 'exiftool -a -b -W %d%f.%s -previewimage' .RAF
# resize images with config picker
try 'mom -DC resize --rename --' +image .jpeg .jpg .png .webp .tiff .bmp

FALLBACK=
BROWSER=
