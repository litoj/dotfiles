#!/usr/bin/env bash

[[ $- != *i* ]] && return

if command -v bat &> /dev/null; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

export VISUAL=nvim
export BROWSER=firefox
export TERM=xterm-256color

export PS1="\[\e[40;1m\]\$([ \$? = 0 ] && echo \[\e[92m\]0 || echo \[\e[91m\]\$?) \[\e[0;40;32m\]\u\[\e[34m\]@\[\e[94m\]\h\[\e[1;93m\]:\[\e[0;40;35m\]\W \$([ \$USER = root ] && echo '\[\e[1;31m\]#' || echo '\[\e[1;32m\]\$')\[\e[0;30m\]\[\e[0m\]"

# move with shift+Left/Right between words
bind '"\e[1;2D": backward-word'
bind '"\e[1;2C": forward-word'

# setup editor
if command -v nvim &> /dev/null; then
	export EDITOR="nvim"
	alias edit="nvim"
	alias v="nvim"
else
	export EDITOR="vim"
	alias edit="vim"
	alias v="vim"
fi

# ls -> exa
if command -v exa &> /dev/null; then
	alias ls='exa -al --color=always --group-directories-first' # my preferred listing
	alias la='exa -a --color=always --group-directories-first'  # all files and dirs
	alias ll='exa -l --color=always --group-directories-first'  # long format
	alias lt='exa -aT --color=always --group-directories-first' # tree listing
else
	if [ "$(uname -a | awk '{print $1}')" != "SunOS" ]; then
		alias ls='ls --group-directories-first --color=auto -al'
		alias la='ls --group-directories-first --color=auto -a'
		alias ll='ls --group-directories-first --color=auto -l'
		alias lt='ls --group-directories-first --color=auto -aT'
	else
		alias ls='ls --color=auto -al'
		alias la='ls --color=auto -a'
		alias ll='ls --color=auto -l'
		alias lt='ls --color=auto -aT'
	fi
fi

# package manager
case $(cat /etc/*-release 2> /dev/null | grep "^ID=" | awk -F '=' '{print $2}' 2> /dev/null) in
	arch)
		alias p="paru"
		alias pr="paru -Rscn"
		alias pu="paru -Syu"
		alias po="paru -Qqtd"
		alias pc="paru -Sc"
		alias pss="paru -S \$(paru -Slq | fzf -m --preview 'paru -Si {1}'  --preview-window=wrap)"
		alias psr="paru -Rscn \$(paru -Qeq | fzf -m --preview 'paru -Si {1}'  --preview-window=wrap)"
		;;
	debian | raspbian)
		alias p="sudo apt"
		alias pr="sudo apt autoremove"
		alias pu="sudo apt update && sudo apt upgrade"
		alias pss="sudo apt install \$(apt list | awk -F \"/\" '{print \$1}' | tail -n +2 | fzf -m --preview 'apt show {1}' --preview-window=wrap)"
		alias psr="sudo apt autoremove \$(apt list --installed | awk -F \"/\" '{print \$1}' | tail -n +2 | fzf -m --preview 'apt show {1}' --preview-window=wrap"
		;;
esac

alias pipu="pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U"
alias spipu="sudo pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo pip install -U"

# navigation
alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../.."
alias .5="cd ../../../..'"
alias .6="cd ../../../../.."

alias se="sudo \$EDITOR"
alias sr="sudo ranger"
alias s="sensors"
alias smci="sudo make clean install"
alias of='$EDITOR $(fzf -e)'
alias cdd="cd ~/dotfiles"
alias fup="cd ~/dotfiles; git pull"
alias gd="git add -A && git commit && git push origin master"
