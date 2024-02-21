#!/usr/bin/env bash

set -e

pr() { echo -e "\033[0;32m[+] ${1}\033[0m"; }
ask() {
	local y
	for ((n = 0; n < 3; n++)); do
		pr "$1"
		if read -r y; then
			if [ "$y" = y ]; then
				return 0
			elif [ "$y" = n ]; then
				return 1
			fi
		fi
		pr "Asking again..."
	done
	return 1
}

pkg install -y figlet

# Display "Lawnchair Magisk" in bigger fonts
figlet "cvnertnc"

pr "Setting up environment..."
apt update -y && apt upgrade -y && pkg install -y openssl git wget jq openjdk-17 zip
rm -rf rvx-app
rm -rf revanced-magisk-module
git clone --depth=1 https://github.com/cvnertnc/rvx-app
cd rvx-app
chmod +x build.sh

if ask "Do you want to open the config.toml for customizations? [y/n]"; then
	nano config.toml
fi
if ! ask "Setup is done. Do you want to start building? [y/n]"; then
	exit 0
fi
./build.sh

cd build
pr "Ask for storage permission"
until
	yes | termux-setup-storage >/dev/null 2>&1
	ls /sdcard >/dev/null 2>&1
do
	sleep 1
done

PWD=$(pwd)
mkdir -p ~/storage/downloads/rvx-app
for op in *; do
	[ "$op" = "*" ] && continue
	mv -f "${PWD}/${op}" ~/storage/downloads/rvx-app/"${op}"
done

pr "Outputs are available in /sdcard/Download/rvx-app folder"
am start -a android.intent.action.VIEW -d file:///sdcard/Download/rvx-app -t resource/folder
sleep 2
am start -a android.intent.action.VIEW -d file:///sdcard/Download/rvx-app -t resource/folder
