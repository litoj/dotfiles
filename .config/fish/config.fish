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
bind \cq exit
bind \b backward-kill-word
bind \e\[3\;5~ kill-word

set fish_color_normal normal
set fish_color_command blue
set fish_color_param brcyan
set fish_color_cwd_root 
set fish_color_operator red
set fish_color_redirection red
set fish_color_end red
set fish_color_quote yellow
set fish_color_escape cc6415
set fish_color_comment grey
set fish_color_autosuggestion grey
set fish_pager_color_description magenta
set fish_pager_color_prefix brcyan --bold
set fish_pager_color_completion grey
set fish_pager_color_progress green --bold
set fish_color_search_match --bold --background=222222
set fish_color_valid_path
set fish_color_error brred

alias ls='eza --icons --colour=always'
alias lt='eza --icons --colour=always -T -L'
alias ll='eza --icons --colour=always -l'
alias la='eza --icons --colour=always -l -a'

abbr man    batman
abbr se     "sudo nvim"
abbr sr     "sudo ranger"
abbr s      "sensors"
abbr cp     "cp -i"
abbr mv     "mv -i"
abbr gparted "xhost +SI:localuser:root && sudo gparted; xhost -SI:localuser:root"
abbr dl     "mom -d"

# get error messages from journalctl
abbr jctl   "journalctl -p 3 -b"

# pacman
set pp "fzf -m --preview 'paru --color=always -Sii {1}' --preview-window=wrap" # package preview
abbr psi    "paru -Slq | $pp | paru -S -" # search install
abbr pif    "paru -Qq | $pp | paru -Ql -" # installed files
abbr pir    "paru -Qq | $pp | paru -Rscn -" # installed remove - only dependencies
abbr piu    "paru -Qttq | $pp | paru -Rscn -" # installed uninstall - only dependents-less
abbr pou    "paru -Qtqd | paru -Rscn -" # orphans remove

# navigation
abbr ...    "cd ../.."
abbr cdd    "cd ~/dotfiles"
abbr cds    "cd ~/Documents/school/"
abbr cdp    "cd ~/Documents/school/PG/"
abbr cdw    "cd ~/Documents/work/projects-fit/"
abbr cdn    "cd ~/Documents/personal/nvim/"
abbr dup    "cd ~/dotfiles; git pull"
abbr gP     "git push"
abbr gPt    "git push origin --tags"
abbr gp     "git pull"
abbr gb     "git checkout -b"
abbr gg     "git checkout"
abbr gs     "git status"
abbr ga     "git add -A && git commit"
abbr gap    "git add -p"
abbr gA     "git add (git ls-files -m | fzf -m)"
abbr gC     "git commit"
abbr gd     "git branch -d (git branch | fzf | sed 's/.* //')"
abbr gc     "git checkout"
abbr gs     "git switch"

# internet related shortcuts
abbr scan   "nmap -T4 -p22 (ip a | sed -nE 's,.*inet (1([^2][^.]|2[^7])\.[0-9]+\.[0-9]+\.)[0-9]+/([0-9]+).*,\10/\3,p')"
abbr ipa    "ip a | sed -n 's/.* \([.0-9]\+\/[0-9]\+\).*/\1/p' | tail -n 1"
abbr npa    "netstat -tn"
abbr npo    "netstat -lutnp &| tail -n +4"
abbr nip    "netstat -utnp &| tail -n +4 | sed 's/ \+/ /g' | cut -d' ' -f1,5,6,7 | sort -k4n -k2n | column -t -R 2"
# shows connected devices
abbr con    "arp -a"
# enable disabled wifi
abbr iwre   "rfkill block wlan && rfkill unblock wlan && sudo ip link set wlo1 up"

abbr fit    "ssh -oHostKeyAlgorithms=ssh-rsa litosjos@fray1.fit.cvut.cz"

# system checks
abbr efil   'for var in (efivar -l); efivar -p -n $var | grep "Name" -A7; end | bat -l yaml'
abbr efig   'efivar -p -n (efivar -l | grep "")'
abbr gefi   'cd /sys/firmware/efi/efivars/'
abbr mefi   'chattr -i'

function fish_user_key_bindings
	fzf_key_bindings
end

if status is-login
	if [ -z "$DISPLAY" -a "$XDG_VTNR" -eq 1 ]
		eval (ssh-agent | head -2 | sed 's/\(.*\)=\(.*\);/set \1 \2;/')
		export FZF_DEFAULT_OPTS="--bind='alt-h:backward-char,alt-j:down,alt-k:up,alt-l:forward-char'"
		export JAVA_HOME=/usr/lib/jvm/default-runtime/ _JAVA_AWT_WM_NONREPARENTING=1
		export QT_QPA_PLATFORMTHEME=qt5ct GDK_BACKEND="wayland,x11"
		export XDG_CURRENT_DESKTOP=sway MOZ_ENABLE_WAYLAND=1
		# for '~' expansion
		set -x XDG_CONFIG_HOME ~/.config
		set -x XDG_CACHE_HOME ~/.cache
		set cache $XDG_CACHE_HOME
		export GRADLE_USER_HOME=$cache/gradle GOPATH=$cache/go MAVEN_HOME=$cache/maven-m2
		export ANDROID_SDK_HOME=$cache/Google/android ANDROID_AVD_HOME=$cache/Google/android/avd
		export CARGO_HOME=$cache/cargo NUGET_PACKAGES=$cache/nuget
		export RADV_PERFTEST=video_decode
		set WLR_RENDERER vulkan
		sway
		killall -15 ssh-agent
	end
end
# vim: ft=bash
