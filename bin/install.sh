#!/usr/bin/env bash
# This I use for my own use, simply put, it installs all the packages I need and puts all theme
# files where I want them. Use only as the user on the machine who you want to affect

if [[ $PWD == *dotfiles* ]]; then
	while [[ $PWD != *dotfiles ]]; do
		if [[ $PWD == *dotfiles* ]]; then
			cd ..
		else
			cd dotfiles
		fi
	done
else
	cd ${0%/bin/install.sh}
fi

if [[ ! $(which paru) ]]; then
	sudo pacman --needed -S git base-devel cargo
	git clone https://aur.archlinux.org/paru-bin.git
	cd paru-bin
	makepkg -si
	cd ..
	rm -rf paru-bin
fi

neovim() {
	printf '\nInstalling neovim LSPs.\n'
	paru --needed -S $(printf '
bash-language-server
clang
eslint
lua-format
lua-language-server
pandoc-bin
prettier
pyright
shellcheck
shfmt
typescript-language-server
vscode-langservers-extracted
yaml-language-server
yapf')
}

# installs packages for latex

latex() {
	paru --needed -S $(printf '
texlab
texlive-bibtexextra
texlive-fontsextra
texlive-formatsextra
texlive-humanities
texlive-latexindent-meta
texlive-pictures
texlive-publishers
texlive-science')
}

# installs all basics aside of system defaults, such as: base, base-devel, linux, git, sudo
basics() {
	printf '\nInstalling basics.\n'
	paru --needed -S $(printf '
acpi
acpid
alsa-utils
arandr
arp-scan
bc
bashmount
bat
cpupower-gui
dragon-drop
dunst
engrampa
exa
fd
feh
fish
fzf
gnu-netcat
go
gparted
grub
htop
i3-gaps
i3blocks
i3lock-fancy-rapid-git
inxi
linux-firmware
lxappearance-gtk3
maim
man-db
man-pages
mpv-mpris
neofetch
neovim
net-tools
network-manager-applet
nerd-fonts-inconsolata
networkmanager
npm
ntfs-3g
openssh
otf-overpass
p7zip
pacman-contrib
pcmanfm-gtk3
picom-ibhagwan-git
pipewire-alsa
pipewire-pulse
playerctl
polkit-gnome
pulsemixer
python-pynvim
qt5ct
ranger
reflector
ripgrep
rofi
rofi-dmenu
sweet-cursor-theme-git
sx
ttf-exo-2
ttf-fira-code
ttf-joypixels
ttf-nova
udisks2
ueberzug
ufw
w3m
wget
wireplumber
xclip
xdotool
xorg-xdpyinfo
xorg-xev
xorg-xgamma
xorg-xinput
xorg-xkbutils
xorg-xkill
xorg-xmodmap
xorg-xrandr
xorg-xwininfo
yt-dlp')
	wget https://archive.archlinux.org/packages/o/otf-font-awesome/otf-font-awesome-5.15.4-1-any.pkg.tar.zst
	paru --noconfirm -U otf-font-awesome*
	rm otf-font-awesome*
	git clone https://github.com/JosefLitos/st.git && cd st && sudo make clean install && cd .. &&
		rm -rf st
	sudo ln -s $PWD/bin/* /usr/local/bin/ && {
		sudo rm /usr/local/bin/install.sh
		sudo rm /usr/local/bin/backlight
		sudo cp bin/backlight /usr/local/bin/
		sudo chown root:root /usr/local/bin/backlight && sudo chmod +s /usr/local/bin/backlight
		sudo systemctl enable NetworkManager
		sudo systemctl enable ufw.service
		sudo systemctl enable acpid
		sudo ln -s $PWD/other/etc-acpi-handler.sh /etc/acpi/handler.sh
		sudo cp other/40-libinput.conf /etc/X11/xorg.conf.d/
		sudo rm -r /var/log/journal
		bat cache --build
	}
}

# GUI applications installation
guis() {
	printf '\nInstalling GUI applications.\n'
	paru --needed -S $(printf '
firefox
gimp
inkscape
jdk-openjdk
jdk8-openjdk
kdenlive-appimage
netbeans
scrcpy
thunderbird
transmission-gtk')
}

configs() {
	printf '\nLinking configs.\n'
	[[ -f /bin/fish ]] && chsh -s /bin/fish
	ln -s $PWD/.bashrc ~/
	ln -s $PWD/.icons ~/
	ln -s $PWD/.gtkrc-2.0 ~/
	mkdir ~/.config
	cd .config
	ln -s $PWD/* ~/.config/
	rm ~/.config/pulse
	mkdir ~/.config/pulse
	ln -s $PWD/pulse/* ~/.config/pulse/
	rm ~/.config/nvim
	mkdir ~/.config/nvim
	mkdir ~/.config/nvim/.git
	ln -s $PWD/nvim/* ~/.config/nvim/
	cd ..
}

theming() {
	printf '\nInstalling themes.\n'
	sudo ln -s $PWD/theming/qtMB-Lime.conf /usr/share/qt5ct/colors/
	[[ -z "$(unzip)" ]] && paru --noconfirm -S unzip
	sudo unzip theming/MB-Lime-3.38_1.9.3.zip -d /usr/share/themes/ > /dev/null
	sudo unzip theming/MB-Olive.zip -d /usr/share/icons/ > /dev/null
}

sysFiles() {
	printf '\nWriting system files.\n'
	sudo bash -c 'printf "EDITOR=nvim\nQT_QPA_PLATFORMTHEME=qt5ct\nPAGER=bat\n" > /etc/environment'
	if [[ -z $(cat /etc/hostname 2> /dev/null) ]]; then
		read -p 'Pick a system/host name: ' hostname
		while [[ $hostname == *" "* ]]; do
			read -p 'Pick a 1 word hostname: ' hostname
		done
	else
		hostname=$(cat /etc/hostname)
	fi
	sudo bash -c 'printf "blacklist pcspkr\nblacklist btusb\n" > /etc/modprobe.d/blacklist.conf'
	sudo bash -c 'printf "LANG=cs_CZ.UTF-8" > /etc/locale.conf'
	sudo sed -i 's/^#\(cs_CZ.U\)/\1/' /etc/locale.gen
	sudo locale-gen
	sudo bash -c 'printf "'$hostname'" > /etc/hostname'
	sudo bash -c 'printf "\n127.0.0.1 localhost\n::1 localhost\n127.0.1.1
	'$hostname'.localdomain '$hostname'" > /etc/hosts'
	sudo sed -i 's/#Color/Color\nILoveCandy/;s/.*IgnorePkg *= *\(.*\)/IgnorePkg = \1 otf-font-awesome/;s/.*ParallelDownloads.*/ParallelDownloads=8/' /etc/pacman.conf
	paru -Sy
	sudo bash -c 'mkdir /etc/systemd/system/getty@tty1.service.d; sed "s/kepis/'$USER'/" \
	other/etc-systemd-system-getty@tty1.service.d-override.conf > \
	/etc/systemd/system/getty@tty1.service.d/override.conf'
	sudo sed -i \
		's/#HandlePowerKey=.*/HandlePowerKey=ignore/;s/#HandleLidSwitch=.*/HandleLidSwitch=ignore/;s/#PowerKeyIgnoreInhibited=.*/PowerKeyIgnoreInhibited=yes/' \
		/etc/systemd/logind.conf
	sudo ln -sf /usr/share/zoneinfo-leaps/Europe/Prague /etc/localtime
}

help() {
	printf "This program was made to simplify my linux reinstallations.
	-b         install basic and essential programms
	-n         install neovim language servers
	-l         install latex packages
	-g         install GUI applications, non-essential
	-c         link config files to these dotfiles
	-t         link and install theme files
	-s         write system files like environment, hostname etc.
	-A         install everything available
	-a         install everything excluding latex and guis
	-h,--help  list this help
	\n"
}

for param in "$@"; do
	case "$param" in
		'-b') basics ;;
		'-g') guis ;;
		'-c') configs ;;
		'-t') theming ;;
		'-s') sysFiles ;;
		'-n') neovim ;;
		'-l') latex ;;
		'-a') # all except latex
			if [[ $USER == root ]]; then
				echo "You have to create a user and be allow in sudoers first."
				exit 0
			fi
			sysFiles
			configs
			basics
			theming
			neovim
			;;
		'-A') # all as in everything
			sysFiles
			configs
			basics
			theming
			guis
			neovim
			latex
			;;
		*) help ;;
	esac
done
