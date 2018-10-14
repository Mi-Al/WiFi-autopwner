#!/bin/bash

# Автор: MiAl
# Домашняя страница скрипта: https://hackware.ru/?p=5209

AIRCRACK_TIMEOUT=5 # Сколько времени дано программе aircrack-ng для считывания файла. Время указывается в секундах
# если у вас очень большой файл или очень медленная система, то увеличьте это значение
DIR="./handshakes/"`date +"%Y-%m-%d-%H%M%S"`
ISDIRCREATED=0

if [[ "$1" && -f "$1" ]]; then
    FILE="$1"
else
    echo 'Укажите .(p)cap файл, из которого нужно извлечь рукопожатия.';
    echo 'Пример запуска:';
    echo -e "\tbash handshakes_extractor.sh wpa.cap";
    exit 1
fi

while read -r "line" ; do
if [ "$(echo "$line" | grep 'WPA' | grep -E -v '(0 handshake)' | grep -E 'WPA \(' | awk -F '  ' '{print $3}')" ]; then
    if [ $ISDIRCREATED -eq 0 ]; then
        mkdir $DIR || (echo "Невозможно создать каталог для сохранения рукопожатий. Выход." && exit 1)
        ISDIRCREATED=1
    fi
    ESSID="$(echo "$line" | grep 'WPA' | grep -E -v '(0 handshake)' | grep -E 'WPA \(' | awk -F '  ' '{print $3}')"
    BSSID="$(echo "$line" | grep 'WPA' | grep -E -v '(0 handshake)' | grep -E 'WPA \(' | awk -F '  ' '{print $2}')"
    echo -e "\033[0;32mНайдено рукопожатие для сети $ESSID ($BSSID). Сохранено в файл $DIR/\033[1m$ESSID.pcap\e[0m"
    tshark -r $FILE -R "(wlan.fc.type_subtype == 0x08 || wlan.fc.type_subtype == 0x05 || eapol) && wlan.addr == $BSSID" -2 2>/dev/null
    tshark -r $FILE -R "(wlan.fc.type_subtype == 0x08 || wlan.fc.type_subtype == 0x05 || eapol) && wlan.addr == $BSSID" -2 -w ./$DIR/"$ESSID.pcap" -F pcap 2>/dev/null
fi
done < <(timeout $AIRCRACK_TIMEOUT aircrack-ng $FILE)
