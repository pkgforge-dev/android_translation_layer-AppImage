#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1
export DEPLOY_GSTREAMER=1
export DEPLOY_PIPEWIRE=1
export ICON="https://gitlab.com/android_translation_layer/android_translation_layer/-/raw/master/doc/logo.svg"

# Deploy dependencies
quick-sharun \
	/usr/bin/android-translation-layer \
	/usr/bin/addr2line                 \
	/usr/bin/dex2oat                   \
	/usr/bin/dalvikvm                  \
	/usr/bin/dx                        \
	/usr/lib/libOpenSLES.so*           \
	/usr/lib/java                      \
	/usr/lib/art                       \
	/usr/share/atl
echo 'ATL_APP_LAUNCHER=$APPIMAGE' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage
