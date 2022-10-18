#!/usr/bin/fish

# java
export _JAVA_AWT_WM_NONREPARENTING=1
# use bat to color man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""'

set -x READER nvim
set -x EDITOR nvim
set -x BROWSER firefox
set -x TERMINAL st

function fish_greeting
end

function fish_title
	printf (basename $PWD)" - Fish"
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

bind  exit

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
set fish_color_autosuggestion brgrey
set fish_pager_color_description magenta
set fish_pager_color_prefix brcyan --bold
set fish_pager_color_completion grey
set fish_pager_color_progress green --bold
set fish_color_search_match --bold --background=222222
set fish_color_valid_path
set fish_color_error brred

alias ls='exa --icons --colour=always'
alias lt='exa --icons --colour=always -T -L'
alias ll='exa --icons --colour=always -l'
alias la='exa --icons --colour=always -l -a'

abbr se			"sudo nvim"
abbr sr 		"sudo ranger"
abbr s 			"sensors"
abbr cp 		"cp -i"
abbr mv 		"mv -i"
abbr smci		"sudo make clean install"

# get error messages from journalctl
abbr jctl 		"journalctl -p 3 -b"

# pacman
abbr pc 		"paru -Sc"
abbr pror 	"paru -Rscn (paru -Qqtd)"
abbr pss 		"paru -S (paru -Slq | fzf -m --preview 'paru -Si {1}'  --preview-window=wrap)"
abbr psr 		"paru -Rscn (paru -Qeq | fzf -m --preview 'paru -Si {1}'  --preview-window=wrap)"

# navigation
abbr ...    "cd ../.."
abbr cds    "cd ~/Documents/PG/litosjos/"
abbr cdd 		"cd ~/dotfiles"
abbr dup 		"cd ~/dotfiles; git pull"
abbr gp			"git push"
abbr gu			"git pull"
abbr gb			"git checkout -b"
abbr gg			"git checkout"
abbr ga			"git add -A && git commit"
abbr gd			"git branch -d (git branch | fzf | sed 's/.* //')"

# quick program info fetch
abbr xp 		"xprop | grep -e '^_NET_WM_WINDOW_TYPE' -e '^WM_NAME' -e '^WM_CLASS' | sed 's/^.*_\(.*\)(.*) = /\1 = /'"
# detect keys pressed
abbr xev 		"xev | grep keysym | awk '{ print \"code \"\$4\", sym \"\$7 }' | sed 's/),//'"
# internet related shortcuts
abbr ipa		"ip a | sed -n 's/.*\(192[.0-9]\+\/[0-9]\+\).*/\1/p'"
abbr scan   "nmap -T4 -p22 (ip a | sed -n 's/.*\(192\.[0-9]\+\.[0-9]\+\.\)[0-9]\+\/\([0-9]\+\).*/\10\/\2/p')"
abbr port	  "netstat -ltnp|grep /"
abbr adl    "adb connect (sudo arp-scan --localnet | grep ^192.168 | awk '{print \$1;EXIT}'):5555"
abbr adh    "adb connect 192.168.0.102:5555"
# shows connected devices
abbr con    "arp -a"

abbr fit		"ssh -oHostKeyAlgorithms=ssh-rsa litosjos@fray1.fit.cvut.cz"
abbr dw			"~/Documents/PG/litosjos/"

function fish_user_key_bindings
	fzf_key_bindings
end

if status is-login
	if test -z "$DISPLAY" -a "$XDG_VTNR" -eq 1
		exec bash -c 'eval $(ssh-agent) && sx i3' 
		# exec startx -- -keeptty
	end
end
