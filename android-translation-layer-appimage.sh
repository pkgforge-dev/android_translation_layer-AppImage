#!/bin/sh

set -eu

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
VERSION="$(cat ~/version)"

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1
export DEPLOY_GSTREAMER=1
export ICON="https://gitlab.com/android_translation_layer/android_translation_layer/-/raw/master/doc/logo.svg"
export OUTNAME=Android_Translation_Layer-"$VERSION"-anylinux-"$ARCH".AppImage

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun \
	/usr/bin/android-translation-layer \
	/usr/lib/libOpenSLES.so*           \
	/usr/lib/java/*                    \
	/usr/lib/java/*/*                  \
	/usr/lib/java/*/*/*                \
	/usr/lib/art/*

cp -rnv /usr/lib/java ./AppDir/lib
cp -rv /usr/share/atl ./AppDir/share

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist
mv -v ~/version     ./dist
