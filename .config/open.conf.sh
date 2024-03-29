#config for ../bin/xdg-open
BROWSER=@$BROWSER
try @'mpv --no-terminal' +video
BLOCKING=1
try 'mpv --no-audio-display' +audio .m3u
BLOCKING=0
try @imv-dir +image
try @zathura .pdf
try @transmission-gtk magnet:
try @thunderbird mailto:
try @engrampa .7z .bz2 .gz .rar .tar .tgz .xz .zip .zst
try 'java -jar' .jar
