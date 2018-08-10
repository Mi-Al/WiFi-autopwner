#!/bin/bash

echo -e "\e[5mОбщая информация о подключении:\033[0m"
echo "Подключение к Wi-Fi сети `iw dev | grep 'ssid' | sed 's/ssid//'`"
echo "Внешний IP: `curl -s suip.biz/ip/`"
# добавить провайдера и координаты?
routerIP=`ip route | grep 'default via ' | cut -d ' ' -f 3 | head -n 1`
echo "IP роутера: $routerIP"
echo "Локальная сеть: `ip route | grep '/' | cut -d ' ' -f 1`"

echo -e "\e[5mСканирование устройств локальной сети:\033[0m"
sudo nmap -PR -PS -PA -PU -T5 192.168.0.0/24

echo -e "\e[5mТестирование роутера на уязвимости:\033[0m"
sudo xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "
sudo routersploit << _EOF_
use scanners/autopwn
set target $routerIP
run
_EOF_
"




