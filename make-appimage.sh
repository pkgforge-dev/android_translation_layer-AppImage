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
echo 'ATL_BINARY_PATH=$APPIMAGE' >> ./AppDir/.env

# This application needs a ssl/certs/java/cacerts file
# It first looks in /etc/ssl/certs/java/cacerts
# if the file is not there it then looks in XDG_DATA_DIRS
# Because not all distros have /etc/ssl/certs/java/cacerts
# We will have to copy the certs into the AppImage instead
# We cannot use symlinks because not all distros use the same
# location for this, for example:
# * archlinux  /etc/ca-certificates/extracted/java-cacerts.jks
# * fedora     /etc/pki/ca-trust/extracted/java/cacerts
# * Ubuntu     No idea! Looks like there is no Java KeyStore by default!
mkdir -p ./AppDir/share/ssl/certs/java
cp -v /etc/ca-certificates/extracted/java-cacerts.jks ./AppDir/share/ssl/certs/java/cacerts



# Turn AppDir into AppImage
quick-sharun --make-appimage
