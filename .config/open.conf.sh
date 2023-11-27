#config for ../bin/xdg-open
BROWSER="@$BROWSER"
try @mpv .mkv .mp4 .webm
try "mpv --no-audio-display" .aac .mp3 .m4a .m3u .flac .ogg .opus .wav
try @imv-dir .png .jpg .jpeg .webp .gif
try @zathura .pdf
try @transmission-gtk magnet:
try @thunderbird mailto:
try @engrampa .7z .gz .rar .tar .tgz .zip .zst
try @work "^https://.*(atlassian|outlook|teams)\." "^https://gitlab.*/ict/"
try "$BROWSER" .html
[[ $EXPLORER ]] || EXPLORER=ranger
