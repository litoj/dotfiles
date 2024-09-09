#config for ../bin/xdg-open
BROWSER=@$BROWSER
TERM_BLOCKING=1
try 'mpv --no-audio-display' +audio .m3u .m4a .mp3
try @'mpv --no-terminal' +video
try @geeqie .raf
try @imv-dir +image
try @zathura .pdf
try @transmission-gtk magnet:
try @thunderbird mailto:
try @engrampa .7z .bz2 .gz .rar .tar .tgz .xz .zip .zst
try 'java -jar' .jar
FALLBACK=$EDITOR
