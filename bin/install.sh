#!/usr/bin/bash
# This I use for my own use, simply put, it installs all the packages I need and puts all theme
# files where I want them. Use only as the user on the machine who you want to affect

cd "${0%bin/install.sh}" || cd ..

if [[ ! $(which paru) ]]; then
	(
		sudo pacman --needed -S git base-devel cargo
		git clone https://aur.archlinux.org/paru-bin.git
		cd paru-bin && makepkg -si
		rm -rf paru-bin
	)
fi

neovim() {
	printf '\nInstalling neovim LSPs.\n'
	echo '
bash-language-server
clang
eslint
jdtls
lua-language-server
pandoc-bin
prettier
pyright
shfmt
stylua
vscode-langservers-extracted
yapf' | paru --needed -S -
	if which java; then
		(
			export JAVA_HOME=/usr/lib/jvm/default-runtime/
			if cd ~/.local/share/; then
				git clone https://github.com/microsoft/java-debug && cd java-debug &&
					./mvnw clean install && cd ..
				git clone https://github.com/microsoft/vscode-java-test && cd vscode-java-test &&
					npm install && npm run build-plugin
			fi
		)
	fi
}

# installs packages for latex

latex() {
	echo '
texlab
texlive-bibtexextra
texlive-fontsextra
texlive-formatsextra
texlive-humanities
texlive-latexindent-meta
texlive-pictures
texlive-publishers
texlive-science' | paru --needed -S -
}

# installs all basics aside of system defaults, such as: base, base-devel, linux, git, sudo
basics() {
	printf '\nInstalling basics.\n'
	# picked hwdec drivers for AMD based on https://wiki.archlinux.org/title/Hardware_video_acceleration#Installation
	echo '
acpi
alsa-utils
arch-install-scripts
arp-scan
bc
bashmount
bat
bat-extras
booster
dragon-drop
dunst
engrampa
eza
fd
fish
foot
fzf
gnu-netcat
gparted
grim
htop
i3blocks
imv
inxi
jq
libva-mesa-driver
linux-firmware
man-db
man-pages
mpv-mpris
neofetch
neovim
net-tools
ttf-inconsolata-nerd
networkmanager
nm-connection-editor
npm
ntfs-3g
openssh
otf-font-awesome
otf-overpass
p7zip
pacman-contrib
pcmanfm-gtk3
pipewire-alsa
pipewire-jack
pipewire-pulse
pulsemixer
python-pynvim
ranger
ripgrep
rofi-lbonn-wayland-only-git
slurp
sunwait
sway
swaybg
swayidle
sweet-cursor-theme-git
ttf-exo-2
ttf-fira-code
ttf-joypixels
ttf-nova
udisks2
ufw
urlencode
wget
wireplumber
wl-clipboard
wlsunset
xdg-desktop-portal-wlr
xdg-desktop-portal-gtk
xdg-utils
xorg-xhost
xorg-xwayland
yt-dlp' | paru --needed -S -
	sudo ln -s "$PWD"/bin/* /usr/local/bin/ && {
		sudo rm /usr/local/bin/install.sh
		sudo gcc -O3 other/backlight.c -o /usr/local/bin/backlight
		sudo sudo chmod +s /usr/local/bin/backlight
		sudo systemctl enable NetworkManager
		sudo systemctl enable ufw.service
		sudo rm -r /var/log/journal
		git clone https://github.com/mariusor/mpris-ctl.git && cd mpris-ctl && 
			sudo CC='gcc -O2' make release install && cd .. && rm -rf mpris-ctl
	}
}

# GUI applications installation
guis() {
	printf '\nInstalling GUI applications.\n'
	echo '
cpupower-gui
firefox
gimp
jdk-openjdk
netbeans
scrcpy
thunderbird
transmission-gtk
qt6-wayland
qt6ct
prismlanucher-bin' | paru --needed -S -
}

configs() {
	printf '\nLinking configs.\n'
	ln -s "$PWD"/.bashrc ~/
	ln -s "$PWD"/.gitconfig ~/
	mkdir ~/.config
	ln -s "$PWD"/.config/* ~/.config/
	bat cache --build
	mkdir -p ~/.local/share/applications/
	ln -s "$PWD"/other/fb.desktop ~/.local/share/applications/fb.desktop
	xdg-mime default fb.desktop inode/directory
	[[ -f /bin/fish ]] && chsh -s /bin/fish
}

theming() {
	ln -s "$PWD"/.gtkrc-2.0 ~/
	cd theming
	printf '\nInstalling themes.\n'
	[[ -z "$(unzip)" ]] && paru --noconfirm -S unzip
	tar -xf *Dark*.tar.xz
	tar -xf *Light*.tar.gz
	mkdir -p ~/.themes
	mv *Dark*/ ~/.themes/Dark
	mv *Light*/ ~/.themes/Light
	mkdir -p ~/.icons/default/ssss
	echo '[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Sweet-cursors' > ~/.icons/default/index.theme
	mv */ ~/.icons/Icons
	cd ..
}

sysFiles() {
	printf '\nWriting system files.\n'
	printf 'EDITOR=nvim\nVISUAL=nvim\nPAGER=bat\n' | sudo tee /etc/environment
	if [[ ! -f /etc/hostname ]]; then
		read -rp 'Pick a system/host name: ' hostname
		while [[ $hostname =~ ' ' ]]; do
			read -rp 'Pick a 1 word hostname: ' hostname
		done
		echo "$hostname" | sudo tee /etc/hostname
	else
		hostname=$(cat /etc/hostname)
	fi
	printf 'blacklist pcspkr\nblacklist btusb\n' | sudo tee /etc/modprobe.d/blacklist.conf
	[[ -f /etc/locale.conf ]] || printf 'LANG=cs_CZ.UTF-8' | sudo tee /etc/locale.conf
	sudo sed -i 's/^#\(cs_CZ.U\)/\1/' /etc/locale.gen
	sudo locale-gen
	printf '127.0.0.1 localhost\n::1 localhost\n127.0.1.1 %s.localdomain %s' "$hostname" "$hostname" | sudo tee /etc/hosts
	sudo sed -i 's/#Color/Color\nILoveCandy/;s/.*ParallelDownloads.*/ParallelDownloads=8/' /etc/pacman.conf
	paru -Syy
	sudo mkdir '/etc/systemd/system/getty@tty1.service.d'
	sudo sed "s/kepis/$USER/g" 'other/etc-systemd-system-getty@tty1.service.d-override.conf' |
		sudo tee '/etc/systemd/system/getty@tty1.service.d/override.conf'
	sudo sed -i \
		's/#HandlePowerKey=.*/HandlePowerKey=ignore/;s/#HandleLidSwitch=.*/HandleLidSwitch=ignore/;s/#PowerKeyIgnoreInhibited=.*/PowerKeyIgnoreInhibited=yes/' \
		'/etc/systemd/logind.conf'
	sudo ln -sf /usr/share/zoneinfo-leaps/Europe/Prague /etc/localtime
}

help() {
	echo 'This program was made to simplify my linux reinstallations.
	-b         install basic and essential programms
	-n         install neovim language servers
	-l         install latex packages
	-g         install GUI applications, non-essential
	-c         link config files to these dotfiles
	-t         link and install theme files
	-s         write system files like environment, hostname etc.
	-A         install everything available
	-a         install everything excluding latex and guis
	-h,--help  list this help'
}

while getopts bgctsnlaA opt; do
	case "$opt" in
		b) basics ;;
		g) guis ;;
		c) configs ;;
		t) theming ;;
		s) sysFiles ;;
		n) neovim ;;
		l) latex ;;
		a) # all except latex
			if [[ $USER == root ]]; then
				echo 'You have to create a user and be allowed in sudoers first.'
				exit 0
			fi
			basics
			sysFiles
			configs
			theming
			neovim
			;;
		A) # all as in everything
			if [[ $USER == root ]]; then
				echo 'You have to create a user and be allowed in sudoers first.'
				exit 0
			fi
			basics
			sysFiles
			configs
			theming
			neovim
			guis
			latex
			;;
		\?) help ;;
	esac
done

(($# == 0)) && help
