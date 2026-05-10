#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    libdecor            \
    libgdiplus          \
    xmlstarlet          \
    openal              \
    pipewire-audio      \
    pipewire-jack       \
    sdl2
#    dotnet-runtime-9.0  \

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
mkdir -p ./AppDir/bin/lib/Content/MeshReplace
ZIP_LINK=$(wget https://api.github.com/repos/alexjyong/Simitone/releases -O - \
      | sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*Linux-x64-Release.zip")
echo "$ZIP_LINK" | awk -F'/' '{tag=$(NF-1); gsub(/^v/, "", tag); print tag; exit}' > ~/version
if [ "$ARCH" = "x86_64" ]; then
if ! wget --retry-connrefused --tries=30 "$ZIP_LINK" -O /tmp/app.zip 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

bsdtar -xvf /tmp/app.zip -C ./AppDir/bin
else
bsdtar -xvf Simitone-Linux-arm64-Release.zip -C ./AppDir/bin
fi
mv -v ./AppDir/bin/Simitone ./AppDir/bin/Simlauncher
rm -f ./AppDir/bin/simitone.desktop
rm -f ./AppDir/bin/lib/*.pdb
