#!/usr/bin/env bash

[[ $- != *i* ]] && return

. /usr/share/bash-completion/bash_completion
if command -v bat &>/dev/null; then
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
if command -v nvim &>/dev/null; then
	export EDITOR="nvim"
	alias edit="nvim"
	alias v="nvim"
else
	export EDITOR="vim"
	alias edit="vim"
	alias v="vim"
fi

# ls -> exa
if command -v exa &>/dev/null; then
	alias ls='eza -al --color=always --group-directories-first' # my preferred listing
	alias la='eza -a --color=always --group-directories-first'  # all files and dirs
	alias ll='eza -l --color=always --group-directories-first'  # long format
	alias lt='eza -aT --color=always --group-directories-first' # tree listing
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
case $(cat /etc/*-release 2>/dev/null | grep "^ID=" | awk -F '=' '{print $2}' 2>/dev/null) in
	arch)
		pp="fzf -m --preview-window=wrap --preview 'paru --color=always -Sii {1}'"
		alias psi="paru -Slq | $pp | paru -S -"     # search install
		alias pif="paru -Qq | $pp | paru -Ql -"     # installed files
		alias pir="paru -Qq | $pp | paru -Rscn -"   # installed remove - only dependencies
		alias piu="paru -Qttq | $pp | paru -Rscn -" # installed uninstall - only dependents-less
		alias pou='paru -Qtqd | paru -Rscn -'       # orphans remove
		;;
	debian | raspbian | ubuntu)
		pp="sed -n 's,/.*,,p' | fzf -m --preview-window=wrap --preview 'apt show -a {1}'"
		alias psi="apt list | $pp | xargs -d '\n' -- apt install"
		alias piu="apt list --installed | $pp | xargs -d '\n' -- apt autoremove"
		;;
esac

# navigation
alias ..="cd .."
alias ...="cd ../.."

alias se='sudo $EDITOR'
alias sr='sudo ranger'
