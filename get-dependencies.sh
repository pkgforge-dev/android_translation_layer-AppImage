#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm pipewire-audio patchelf

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-mesa libxml2-mini opus-mini gdk-pixbuf2-mini librsvg-mini

# Comment this out if you need an AUR package
make-aur-package --chaotic-aur android_translation_layer-git

# the art_standalone package is broken since it links to a no longer existing version of icu
# try to fix it with a hack
l=/usr/lib/java/dex/art/natives/libjavacore.so
patchelf --replace-needed libicuuc.so.76 libicui18n.so "$l"
patchelf --replace-needed libicui18n.so.76 libicui18n.so "$l"
