#!/usr/bin/env bash

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## If the option `use_preview_script` is set to `true`,
## then this script will be called and its output will be displayed in ranger.
## ANSI color codes are supported.
## STDIN is disabled, so interactive scripts won't work properly

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade ranger.

## Because of some automated testing we do on the script #'s for comments need
## to be doubled up. Code that is commented out, because it's an alternative for
## example, gets only one #.

## Meanings of exit codes:
## code | meaning    | action of ranger
## -----+------------+-------------------------------------------
## 0    | success    | Display stdout as preview
## 1    | no preview | Display no preview at all
## 2    | plain text | Display the plain content of the file
## 3    | fix width  | Don't reload when width changes
## 4    | fix height | Don't reload when height changes
## 5    | fix both   | Don't ever reload
## 6    | image      | Display the image `$IMAGE_CACHE_PATH` points to as an image preview
## 7    | image      | Display the file directly as an image

## Script arguments
FILE_PATH="${1}" # Full path of the highlighted file
PV_WIDTH="${2}"  # Width of the preview pane (number of fitting characters)
## shellcheck disable=SC2034 # PV_HEIGHT is provided for convenience and unused
PV_HEIGHT="${3}"        # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH="${4}" # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}" # 'True' if image previews are enabled, 'False' otherwise.

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="${FILE_EXTENSION,,}"

## Settings
HIGHLIGHT_SIZE_MAX=262143 # 256KiB
HIGHLIGHT_TABWIDTH="${HIGHLIGHT_TABWIDTH:-8}"
HIGHLIGHT_STYLE="${HIGHLIGHT_STYLE:-pablo}"
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE="${PYGMENTIZE_STYLE:-autumn}"
OPENSCAD_IMGSIZE="${RNGR_OPENSCAD_IMGSIZE:-1000,1000}"
OPENSCAD_COLORSCHEME="${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}"

imageExif() {
	exiftool "$FILE_PATH" |
		awk '/^(Rating|Bright|Exposure (Time|Comp)|F Number|Focal Length.*\(|ISO)/' |
		sort
	exit 5
}

bat=(bat --color=always --style=plain --tabs 2)

handle_extension() {
	case "${FILE_EXTENSION_LOWER}" in
		## Archive
		a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | lzh | lzma | lzo | \
			rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip)
			exit 1
			;;
		rar)
			## Avoid password prompt by providing empty password
			unrar lt -p- -- "${FILE_PATH}" && exit 5
			exit 1
			;;
		7z)
			## Avoid password prompt by providing empty password
			7z l -p -- "${FILE_PATH}" && exit 5
			exit 1
			;;

		## PDF
		pdf)
			## Preview as text conversion
			pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - |
				fmt -w "${PV_WIDTH}" && exit 5
			mutool draw -F txt -i -- "${FILE_PATH}" 1-10 |
				fmt -w "${PV_WIDTH}" && exit 5
			exiftool "${FILE_PATH}" && exit 5
			exit 1
			;;

		## BitTorrent
		torrent)
			transmission-show -- "${FILE_PATH}" && exit 5
			exit 1
			;;

		## OpenDocument
		odt | sxw)
			## Preview as text conversion
			odt2txt "${FILE_PATH}" && exit 5
			## Preview as markdown conversion
			pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
			exit 1
			;;
		ods | odp)
			## Preview as text conversion (unsupported by pandoc for markdown)
			odt2txt "${FILE_PATH}" && exit 5
			exit 1
			;;

		## XLSX
		xlsx)
			## Preview as csv conversion
			## Uses: https://github.com/dilshod/xlsx2csv
			xlsx2csv -- "${FILE_PATH}" && exit 5
			exit 1
			;;
		## JSON
		json | mcmeta | ts | js)
			"${bat[@]}" -- "${FILE_PATH}" && exit 5
			JQ_COLORS="0;34:0;34:0;34:0;95:0;33:0;31:0;31" jq -C . "${FILE_PATH}" && exit 5
			;;
		ipynb)
			JQ_COLORS="0;34:0;34:0;34:0;95:0;33:0;31:0;31" jq -C . "${FILE_PATH}" && exit 5
			python -m json.tool -- "${FILE_PATH}" && exit 5
			;;

		## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected
		## by file(1).
		dff | dsf | wv | wvc | html | htm | xhtml)
			"${bat[@]}" -- "${FILE_PATH}" && exit 5
			mediainfo "${FILE_PATH}" && exit 5
			exiftool "${FILE_PATH}" && exit 5
			;; # Continue with next handler on failure
		config | conf | cfg | sln)
			"${bat[@]}" -l cfg -- "${FILE_PATH}" && exit 5
			;;
		csproj)
			"${bat[@]}" -l xml -- "${FILE_PATH}" && exit 5
			;;
	esac
}

handle_image() {
	## Size of the preview if there are multiple options or it has to be
	## rendered from vector graphics. If the conversion program allows
	## specifying only one dimension while keeping the aspect ratio, the width
	## will be used.
	local DEFAULT_SIZE="1280x720"

	case "$MIMETYPE" in
		## SVG
		image/svg+xml | image/svg)
			magick -- "${FILE_PATH}" "${IMAGE_CACHE_PATH}" && exit 6
			exit 1
			;;

		image/x-fuji-raf)
			(($(stat -c %Y "${FILE_PATH}") > $(date +%s))) && touch -m "${FILE_PATH}"
			exiftool -b -PreviewImage "${FILE_PATH}" -W "${IMAGE_CACHE_PATH}" && exit 6
			imageExif
			;;

		## Image
		image/*)
			exit 7
			;;

		# PDF
		application/pdf)
			pdftoppm -f 1 -l 1 \
				-scale-to-x "${DEFAULT_SIZE%x*}" \
				-scale-to-y -1 \
				-singlefile \
				-jpeg -tiffcompression jpeg \
				-- "${FILE_PATH}" "${IMAGE_CACHE_PATH%.*}" &&
				exit 6 || exit 1
			;;

			## ePub, MOBI, FB2 (using Calibre)
			# application/epub+zip|application/x-mobipocket-ebook|\
			# application/x-fictionbook+xml)
			#     # ePub (using https://github.com/marianosimone/epub-thumbnailer)
			#     epub-thumbnailer "${FILE_PATH}" "${IMAGE_CACHE_PATH}" \
			#         "${DEFAULT_SIZE%x*}" && exit 6
			#     ebook-meta --get-cover="${IMAGE_CACHE_PATH}" -- "${FILE_PATH}" \
			#         >/dev/null && exit 6
			#     exit 1;;

	esac

	case "${FILE_EXTENSION_LOWER}" in
		cr3)
			exiftool -b -PreviewImage "${FILE_PATH}" -W "${IMAGE_CACHE_PATH}" && exit 6
			imageExif && exit 5
			;;
	esac
}

handle_mime() {
	local mimetype="${1}"
	case "${mimetype}" in
		## RTF and DOC
		text/rtf | *msword)
			## Preview as text conversion
			## note: catdoc does not always work for .doc files
			## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
			catdoc -- "${FILE_PATH}" && exit 5
			exit 1
			;;

		## DOCX, ePub, FB2 (using markdown)
		## You might want to remove "|epub" and/or "|fb2" below if you have
		## uncommented other methods to preview those formats
		*wordprocessingml.document | */epub+zip | */x-fictionbook+xml)
			## Preview as markdown conversion
			pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
			exit 1
			;;

		## E-mails
		message/rfc822)
			## Parsing performed by mu: https://github.com/djcb/mu
			mu view -- "${FILE_PATH}" && exit 5
			exit 1
			;;

		## XLS
		*ms-excel)
			## Preview as csv conversion
			## xls2csv comes with catdoc:
			##   http://www.wagner.pp.ru/~vitus/software/catdoc/
			xls2csv -- "${FILE_PATH}" && exit 5
			exit 1
			;;

		## Text
		text/* | */xml | application/javascript)
			## Syntax highlight
			if [[ "$(stat --printf='%s' -- "${FILE_PATH}")" -gt ${HIGHLIGHT_SIZE_MAX} ]]; then
				exit 2
			fi
			if [[ "$(tput colors)" -ge 256 ]]; then
				local pygmentize_format='terminal256'
				local highlight_format='xterm256'
			else
				local pygmentize_format='terminal'
				local highlight_format='ansi'
			fi
			env HIGHLIGHT_OPTIONS="${HIGHLIGHT_OPTIONS}" highlight \
				--out-format="${highlight_format}" \
				--force -- "${FILE_PATH}" && exit 5
			bat --color=always --tabs 2 --style="plain" -- "${FILE_PATH}" && exit 5
			pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}" \
				-- "${FILE_PATH}" && exit 5
			exit 2
			;;

		## Image
		image/*)
			## Preview as text conversion
			imageExif
			exit 1
			;;

		## Video and audio
		video/* | audio/*)
			mediainfo "${FILE_PATH}" && exit 5
			exiftool "${FILE_PATH}" && exit 5
			exit 1
			;;

		## ELF files (executables and shared objects)
		application/x-executable | application/x-pie-executable | application/x-sharedlib)
			readelf -WCa "${FILE_PATH}" && exit 5
			exit 1
			;;
	esac
}

handle_fallback() {
	echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit 5
	exit 1
}

MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"
if [[ ${PV_IMAGE_ENABLED} == 'True' ]]; then
	handle_image "${MIMETYPE}"
fi
handle_extension
handle_mime "${MIMETYPE}"
handle_fallback
