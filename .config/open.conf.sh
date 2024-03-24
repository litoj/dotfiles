#config for ../bin/xdg-open
BROWSER=@$BROWSER
try @'mpv --no-terminal' .mkv .mp4 .webm
BLOCKING=1
try 'mpv --no-audio-display' .aac .mp3 .m4a .m3u .flac .ogg .opus .wav .wma
BLOCKING=0
try @imv-dir .png .jpg .jpeg .webp .gif .svg
try @zathura .pdf
try @transmission-gtk magnet:
try @thunderbird mailto:
try @engrampa .7z .bz2 .gz .rar .tar .tgz .xz .zip .zst
try 'java -jar' .jar
[[ $EXPLORER ]] || EXPLORER=ranger
