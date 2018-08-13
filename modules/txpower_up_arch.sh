#!/bin/bash

sudo pacman -S crda wireless-regdb --needed

mkdir /tmp/temp_tx
cd /tmp/temp_tx

git clone https://aur.archlinux.org/wireless-regdb-pentest.git
if [ $? -ne '0' ]; then
	echo "Не получилось склонировать репозиторий. Нет Интернета?"
	echo "Fail! No Internet?"
	exit 1
fi

cd wireless-regdb-pentest
makepkg -si

cd ..
rm -rf /tmp/temp_tx/
