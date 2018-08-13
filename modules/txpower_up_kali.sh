#!/bin/bash

mkdir /tmp/temp_tx
cd /tmp/temp_tx

git clone git://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git
if [ $? -ne '0' ]; then
	echo "Не получилось склонировать репозиторий. Нет Интернета?"
	echo "Fail! No Internet?"
	exit 1
fi

cd wireless-regdb/
wget "https://aur.archlinux.org/cgit/aur.git/plain/db.txt.patch?h=wireless-regdb-pentest" -O db.txt.patch
patch -Np1 -i ./db.txt.patch

wget "https://aur.archlinux.org/cgit/aur.git/plain/db.txt2.patch?h=wireless-regdb-pentest" -O db.txt2.patch
patch -Np0 -i ./db.txt2.patch

make
if [ $? -ne '0' ]; then
	echo "Ошибка сборки. Не хватает библиотек?"
	echo "Build error. There are no necessary libraries?"
	exit 1
fi
sudo rm /lib/crda/regulatory.bin
sudo cp regulatory.bin /lib/crda/regulatory.bin
sudo cp $USER.key.pub.pem /lib/crda/pubkeys/

cd ..
rm -rf /tmp/temp_tx/
