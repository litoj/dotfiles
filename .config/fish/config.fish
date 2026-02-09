#!/usr/bin/fish

set -x READER nvim
set -x EDITOR nvim
set -x BROWSER firefox
set -x FZF_DEFAULT_COMMAND 'rg --hidden -l ""'
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

function fish_greeting
end

function fish_title
	printf "Fish - "(basename $PWD)
end

function fish_prompt
	set -l last_status $status
	set_color -b black
	[ $last_status = 0 ] && set_color brgreen -o || set_color brred -o
		printf "$last_status "
	set_color normal
	set_color -b black
	set_color blue
		printf '@'
	set_color brblue
		printf $hostname
	set_color bryellow -o
		printf ':'
	set_color normal
	set_color -b black
	set_color magenta
		printf (basename $PWD)' '
	if [ "$USER" = 'root' ]
		set_color red -o
			printf '#'
	else
		set_color green -o
		printf '$'
	end
	set_color normal
	set_color black
		printf ' '
	set_color normal

	# del key does not work properly by itself
	printf '\033[?1h\033=' >/dev/tty
end

# https://fishshell.com/docs/3.1/cmds/bind.html
# fish_key_reader
bind \cq exit
bind \e\[1\;5C clear # nvim leonerd vtty encoding
bind \b backward-kill-word
bind \e\[3\;5~ kill-word

set --global fish_color_normal normal
set --global fish_color_command blue
set --global fish_color_param brcyan
set --global fish_color_cwd_root 
set --global fish_color_operator red
set --global fish_color_redirection red
set --global fish_color_end red
set --global fish_color_quote yellow
set --global fish_color_escape cc6415
set --global fish_color_comment grey
set --global fish_color_autosuggestion grey
set --global fish_pager_color_description magenta
set --global fish_pager_color_prefix brcyan --bold
set --global fish_pager_color_completion grey
set --global fish_pager_color_progress green --bold
set --global fish_color_search_match --bold --background=222222
set --global fish_color_redirection brmagenta
set --global fish_color_error brred

alias ls='eza --icons'
alias lt='eza --icons -T -L'
alias ll='eza --icons -l'
alias la='eza --icons -l -a'

abbr man    batman
abbr se     'sudoedit'
abbr sr     'sudo ranger'
abbr s      'sensors'
abbr cp     'cp -i'
abbr mv     'mv -i'
abbr gparted 'xhost +SI:localuser:root && sudo gparted; xhost -SI:localuser:root'

function setpy
end


# get error messages from journalctl
abbr jctl   'journalctl -p 3 -b'

# pacman
set --global pm paru
set pp "fzf -m --preview-window=wrap --preview '\$pm --color=always -Sii {1}'" # package preview
abbr psi    "\$pm -S (\$pm -Slq | $pp)" # search install
abbr pif    "\$pm -Ql (\$pm -Qq | $pp)" # list installed files
abbr pir    "\$pm -Rscn (\$pm -Qq | $pp)" # installed remove - only dependencies
abbr piu    "\$pm -Rscn (\$pm -Qttq | $pp)" # installed uninstall - only dependents-less / roots
abbr pou    "\$pm -Rscn (\$pm -Qtqd)" # orphans remove
abbr pis    "\$pm -S (\$pm -Qq | $pp)" # installed search and sync

# navigation
abbr ...    'cd ../..'
abbr cdd    'cd ~/dotfiles'
alias cdr='ranger --choosedir=/tmp/cwd && cd (cat /tmp/cwd) && rm /tmp/cwd'
abbr dup    'cd ~/dotfiles; git pull'
# git
abbr gp     'git pull'
abbr gA     'git add -A && git commit'
abbr ga     'git add -v (git lf | fzf -m | sed "s/..//")'
abbr gC     'git commit'
abbr gr     'git rebase'
abbr grc    'git rebase --continue'
abbr grf    'git checkout <branch>^ --' # restore file
abbr gff    'git log --all -1 --' # go find file
abbr gP     'git push'
abbr gbP    'git push origin HEAD:'
abbr gdP    'git push -d origin'
abbr gtP    'git push origin --tags'
abbr gd     'git branch -d (git branch | fzf | sed "s/.* //")'
abbr gb     'git checkout -b'

# internet related shortcuts
abbr scan   "nmap -T4 -p22 (ip a | sed -nE 's,.*inet (1([^2][^.]|2[^7])\.[0-9]+\.[0-9]+\.)[0-9]+/([0-9]+).*,\10/\3,p')"
abbr ipa    "ip a | sed -n 's/.* \([.0-9]\+\/[0-9]\+\).*/\1/p' | tail -n 1"
abbr npa    "netstat -tn"
abbr npo    "netstat -lutnp &| tail -n +4"
abbr nip    "netstat -utnp &| tail -n +4 | sed 's/ \+/ /g' | cut -d' ' -f1,5,6,7 | sort -k4n -k2n | column -t -R 2"
abbr iwre   'rfkill block wlan && rfkill unblock wlan && sudo ip link set wlo1 up && sudo systemctl restart NetworkManager'
# shows connected devices
abbr con    'arp -a'
abbr sync   'rsync -rltvuP --exclude="Music/Father/" --exclude="Pictures/Darktable/" --delete ~/Pictures ~/Music /run/media/$USER/Elements/zaloha/linux/'
abbr sand   'adb push --sync ~/Pictures/sdcard/Pictures /sdcard/ && adb push --sync ~/Music/Songs /sdcard/Music/'
abbr ap     'adb push --sync'
abbr revsync   'rsync -rltvuP /run/media/$USER/Elements/zaloha/linux/Pictures ~'
abbr sydoc   'rsync -rltvuPC --exclude="__*" --exclude=bin --exclude=node_modules --exclude=work ~/Documents /run/media/$USER/Elements/zaloha/linux/'

abbr fit    'ssh -oHostKeyAlgorithms=ssh-rsa litosjos@fray1.fit.cvut.cz'
abbr getcert 'gnutls-cli --save-cert=myvpn.pem --insecure'

# system checks
abbr efil   'for var in (efivar -l); efivar -p -n $var | grep "Name" -A7; end | bat -l yaml'
abbr efig   'efivar -p -n (efivar -l | grep "")'
abbr gefi   'cd /sys/firmware/efi/efivars/'
abbr mefi   'chattr -i'
abbr od     'od -xc --endian big -N 100'

if status is-login && test -z "$DISPLAY" -a "$XDG_VTNR" -eq 1
	export (ssh-agent | sed -n 's/^\([^ ]*\);.*/\1/p')
	export FZF_DEFAULT_OPTS="--bind='alt-h:backward-char,alt-j:down,alt-k:up,alt-l:forward-char'"
	export JAVA_HOME=/usr/lib/jvm/default-runtime/ _JAVA_AWT_WM_NONREPARENTING=1
	export WINDEDEBUG=-all
	# for '~' expansion
	set -x XDG_CONFIG_HOME ~/.config
	set -x XDG_CACHE_HOME ~/.cache
	set -x XDG_DATA_HOME ~/.local/share
	set cache $XDG_CACHE_HOME
	export GRADLE_USER_HOME=$cache/gradle GOPATH=$cache/go
	export ANDROID_SDK_HOME=$cache/Google/android ANDROID_AVD_HOME=$cache/Google/android/avd
	export CARGO_HOME=$cache/cargo NUGET_PACKAGES=$cache/nuget
	export TEXMFHOME=$cache/texlive2020
	export QT_QPA_PLATFORMTHEME=qt5ct RADV_PERFTEST=video_decode
	export XDG_CURRENT_DESKTOP=sway MOZ_ENABLE_WAYLAND=1 GDK_BACKEND="wayland"
	export PATH="$HOME/.pyenv/shims:$PATH"
	WLR_RENDERER=vulkan sway &>/dev/null < /dev/null # to disable stdin and not cause term apps to open in tty
	killall -15 ssh-agent
else if status --is-interactive && test -f .python-version -o -f ../.python-version
	pyenv init - | source
	# pyenv activate (cat .python-version ../.python-version 2>/dev/null)
end
# vim: ft=bash
