#!/usr/bin/bash
# This I use for my own use, simply put, it installs all the packages I need and puts all theme
# files where I want them. Use only as the user on the machine who you want to affect

cd "${0%install.sh}.." 2>/dev/null || cd ..

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
acpid
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
networkmanager
nm-connection-editor
nmap
npm
ntfs-3g
openssh
otf-font-awesome
otf-overpass
otf-stix
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
swayimg
sweet-cursor-theme-git
ttf-exo-2
ttf-fira-code
ttf-jetbrains-mono
ttf-joypixels
ttf-nerd-fonts-symbols-mono
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
		sudo chmod +s /usr/local/bin/backlight
		sudo systemctl enable NetworkManager
		sudo systemctl enable ufw.service
		sudo rm -r /var/log/journal
		git clone https://github.com/mariusor/mpris-ctl.git && cd mpris-ctl &&
			sudo CC='gcc -O2' make release install && cd .. && rm -rf mpris-ctl
		acpi=/etc/acpi/events/anything
		sudo systemctl enable acpid && sudo rm $acpi && sudo touch $acpi
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
prismlanucher-qt5-bin
ripcord
scrcpy
thunderbird
transmission-gtk
qt5-wayland
qt5ct' | paru --needed -S -
}

configs() {
	printf '\nLinking configs.\n'
	ln -s "$PWD"/.bashrc ~/
	ln -s "$PWD"/.gitconfig ~/
	mkdir ~/.config
	ln -s "$PWD"/.config/* ~/.config/
	bat cache --build
	mkdir -p ~/.local/share/applications/
	ln -s "$PWD"/other/*.desktop ~/.local/share/applications/
	local mimes=($(sed -n 's/^MimeType=//;s/;/ /gp' other/opener.desktop))
	for mime in ${mimes[@]}; do
		xdg-mime default opener.desktop $mime
	done
	[[ -f /bin/fish ]] && chsh -s /bin/fish
	gsettings set org.gtk.Settings.FileChooser sort-directories-first true

	local name
	mkdir -p ~/.cache/
	for name in ranger thumbnails ueberzugpp; do
		ln -s /tmp/cache ~/.cache/$name
	done
	mkdir -p ~/.local/state/nvim/
	for name in dapui.log log lsp.log luasnip.log nio.log; do
		ln -s /tmp/my/log ~/.local/state/nvim/$name
	done
}

theming() {
	cd theming
	printf '\nInstalling themes.\n'
	[[ -z "$(unzip)" ]] && paru --noconfirm -S unzip
	for f in *.tar.*; do tar -xf "$f"; done
	if [[ $THEME_LOCAL ]]; then
		mkdir -p ~/.themes
		mv *Dark*/ ~/.themes/Dark
		mv *Light*/ ~/.themes/Light
		mkdir -p ~/.icons/default/
		echo '[Icon Theme]
Inherits=Sweet-cursors' >~/.icons/default/index.theme
		mv */ ~/.icons/Icons
	else
		local dark=/usr/share/themes/Dark light=/usr/share/themes/Light icons=/usr/share/icons/Icons
		[[ -d $dark ]] && sudo rm -r "$dark"
		sudo mv *Dark*/ "$dark"
		[[ -d $light ]] && sudo rm -r "$light"
		sudo mv *Light*/ "$light"
		sudo sed -i 's/^\(Inherits=\).*$/\1Sweet-cursors/' /usr/share/icons/default/index.theme
		[[ -d $icons ]] && sudo rm -r "$icons"
		sudo mv */ "$icons"
	fi
	[[ -f ~/.gtkrc-2.0 ]] && rm ~/.gtkrc-2.0
	ln -s /tmp/my/gtk2rc ~/.gtkrc-2.0
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
