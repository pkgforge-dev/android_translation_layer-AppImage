#!/bin/sh

set -eu

EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"
PACKAGE_BUILDER="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/make-aur-package.sh"

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
./make-aur-package.sh --chaotic-aur android_translation_layer-git

pacman -Q android_translation_layer-git | awk '{print $2; exit}' > ~/version
