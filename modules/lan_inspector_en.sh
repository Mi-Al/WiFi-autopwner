#!/bin/bash

echo -e "\e[5mConnection Summary:\033[0m"
echo "Wi-Fi Network: `iw dev | grep 'ssid' | sed 's/ssid//'`"
echo "Public IP: `curl -s suip.biz/ip/`"
# добавить провайдера и координаты?
routerIP=`ip route | grep 'default via ' | cut -d ' ' -f 3 | head -n 1`
echo "Router IP: $routerIP"
localNetwork="$(ip route | grep '/' | cut -d ' ' -f 1)"
echo "Local Network: $localNetwork"

echo -e "\e[5mСканирование устройств локальной сети:\033[0m"
sudo nmap -PR -PS -PA -PU -T5 $localNetwork

echo -e "\e[5mIs the router vulnerable?:\033[0m"

PORT=80
is8080="$(sudo nmap -p 8080 --open -T5 -oG - $routerIP | grep -E '8080/open/tcp//http///')"

if [[ "$is8080" ]]; then
   PORT=8080
fi

sudo xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "
sudo routersploit << _EOF_
use scanners/autopwn
set target $routerIP
set http_port $PORT
run
_EOF_
"




