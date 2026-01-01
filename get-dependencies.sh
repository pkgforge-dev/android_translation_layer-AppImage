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
wget 'https://archive.archlinux.org/packages/i/icu/icu-76.1-1-x86_64.pkg.tar.zst' -O ./icu.pkg.tar.zst
tar xvf ./icu.pkg.tar.zst
cp -rn ./usr/lib/* /usr/lib

# we need to build a library to preload to fix an issue with the generated desktop 
# entries having the full path to the tmp binary mountpoint instead of the appimage
cc -shared -fPIC -O2 -Wall -Wextra -o libfixargv0.so fixargv0.c -ldl
mkdir -p ./AppDir/shared/lib
cp -v ./libfixargv0.so ./AppDir/shared/lib
echo 'libfixargv0.so' >> ./AppDir/.preload
