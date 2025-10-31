#!/bin/sh

set -eu

ARCH="$(uname -m)"
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel             \
	cmake                  \
	curl                   \
	git                    \
	libpulse               \
	libx11                 \
	libxrandr              \
	libxss                 \
	pulseaudio             \
	pulseaudio-alsa        \
	pipewire-audio         \
	wget                   \
	xorg-server-xvfb       \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-mesa libxml2-mini opus-mini gdk-pixbuf2-mini

echo "Building android-translation-layer..."
echo "---------------------------------------------------------------"
sed -i -e 's|EUID == 0|EUID == 69|g' /usr/bin/makepkg
sed -i \
	-e 's|MAKEFLAGS=.*|MAKEFLAGS="-j$(nproc)"|'  \
	-e 's|#MAKEFLAGS|MAKEFLAGS|'                 \
	/etc/makepkg.conf
cat /etc/makepkg.conf

# does not build in CI 
#System has not been booted with systemd as init system (PID 1). Can't operate
#
#git clone --depth 1 https://aur.archlinux.org/yay-bin.git ./yay
#(
#	cd ./yay
#	makepkg -fs --noconfirm
#	ls -la .
#	pacman --noconfirm -U ./*.pkg.tar.*
#)
	
#yay -S --noconfirm android_translation_layer-git

pacman-key --init
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo '[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf
pacman -Syu --noconfirm android_translation_layer-git

pacman -Q android_translation_layer-git | awk '{print $2; exit}' > ~/version
