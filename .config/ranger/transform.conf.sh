BLOCKING=1

case "$KIND" in
	resizeOrExtractPreview)
		toCommonAudio() {
			for f in "$@"; do
				ffmpeg -hide_banner -i "$f" "${f%.*}.m4a"
			done
		}
		try @toCommonAudio +audio .opus .flac .wav
		# extract image previews
		try 'exiftool -b -W %d%f.%s -previewimage' .RAF
		# resize images with config picker
		try 'mom -DC resize --rename --' +image .jpeg .jpg .png .webp .tiff .bmp
		;;
	renameOrRawToJPG)
		rawToJPG() {
			local base=/tmp/raw_to_jpg
			mkdir -p "$base"
			for f in "$@"; do
				local name=${f##*/}
				local out="$base/${name%.*}.jpg"
				magick "$f" "$out"
				exiftool -TagsFromFile "$f" -all:all -overwrite_original "$out"
			done
		}
		try @rawToJPG .RAF

		try 'mom rename --' +image .jpeg .jpg +video
		;;
esac

FALLBACK=
BROWSER=
