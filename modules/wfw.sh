#!/bin/bash
 
if [[ "$1" && -f "$1" ]]; then
    FILE="$1"
else
    echo 'Укажите .csv файл, который вы хотите проанализировать.';
    echo 'Пример запуска:';
    echo -e "\tbash wfw.sh /tmp/test-01.csv";
    exit   
fi
 
echo -e "\033[1mВсего точек доступа: \033[0;31m`grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){14}' $FILE | wc -l`\e[0m"
echo -e "\033[1mВсего клиентов: \033[0;31m`grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){5} ([A-Z0-9:]{17})|(not associated)' $FILE | wc -l`\e[0m"
echo -e "\033[1mИз них клиентов без ассоциации: \033[0;31m`grep -E '(not associated)' $FILE | wc -l`\e[0m"
 
echo -e "\033[0;36m\033[1mИнформация о сетях:\e[0m"
 
while read -r line ; do
 
    if [ "`echo "$line" | cut -d ',' -f 14`" != " " ]; then
        echo -e "\033[1m" `echo -e "$line" | cut -d ',' -f 14` "\e[0m"
    else
        echo -e " \e[3mне удалось получить имя сети\e[0m"
    fi
 
    fullMAC=`echo "$line" | cut -d ',' -f 1`
    echo -e "\tMAC-адрес: $fullMAC"
 
    MAC=`echo "$fullMAC" | sed 's/ //g' | sed 's/-//g' | sed 's/://g' | cut -c1-6`
 
    result="$(grep -i -A 1 ^$MAC ./oui.txt)";
  
    if [ "$result" ]; then
        echo -e "\tПроизводитель: `echo "$result" | cut -f 3`"
    else
        echo -e "\tПроизводитель: \e[3mИнформация не найдена в базе данных.\e[0m"
    fi
 
    is5ghz=`echo "$line" | cut -d ',' -f 4 | grep -i -E '36|40|44|48|52|56|60|64|100|104|108|112|116|120|124|128|132|136|140'`
 
    if [ "$is5ghz" ]; then
        echo -e "\t\033[0;31mРаботает на 5 ГГц!\e[0m"
    fi
 
    printonce="\tИнформация о подключённых клиентах:"
 
    while read -r line2 ; do
 
        clientsMAC=`echo $line2 | grep -E "$fullMAC"`
        if [ "$clientsMAC" ]; then
 
            if [ "$printonce" ]; then
                echo -e $printonce
                printonce=''
            fi
 
            echo -e "\t\t\033[0;32m" `echo $clientsMAC | cut -d ',' -f 1` "\e[0m"
            MAC2=`echo "$clientsMAC" | sed 's/ //g' | sed 's/-//g' | sed 's/://g' | cut -c1-6`
 
            result2="$(grep -i -A 1 ^$MAC2 ./oui.txt)";
  
            if [ "$result2" ]; then
                echo -e "\t\t\tПроизводитель: `echo "$result2" | cut -f 3`"
                ismobile=`echo $result2 | grep -i -E 'Olivetti|Sony|Mobile|Apple|Samsung|HUAWEI|Motorola|TCT|LG|Ragentek|Lenovo|Shenzhen|Intel|Xiaomi|zte'`
                warning=`echo $result2 | grep -i -E 'ALFA|Intel'`
                if [ "$ismobile" ]; then
                    echo -e "\t\t\t\033[0;33mВероятно, это мобильное устройство\e[0m"
                fi
 
                if [ "$warning" ]; then
                    echo -e "\t\t\t\033[0;31;5;7mУстройство может поддерживать режим монитора\e[0m"
                fi
 
            else
                echo -e "\t\t\tПроизводитель: \e[3mИнформация не найдена в базе данных.\e[0m"
            fi
 
            probed=`echo $line2 | cut -d ',' -f 7`
 
            if [ "`echo $probed | grep -E [A-Za-z0-9_\\-]+`" ]; then
                echo -e "\t\t\tИскал сети: $probed"
            fi         
        fi
    done < <(grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){5} ([A-Z0-9:]{17})|(not associated)' $FILE)
     
done < <(grep -E '([A-Za-z0-9._: @\(\)\\=\[\{\}\"%;-]+,){14}' $FILE)
 
echo -e "\033[0;36m\033[1mИнформация о неподключённых клиентах:\e[0m"
 
while read -r line2 ; do
 
    clientsMAC=`echo $line2  | cut -d ',' -f 1`
 
    echo -e "\033[0;31m" `echo $clientsMAC | cut -d ',' -f 1` "\e[0m"
    MAC2=`echo "$clientsMAC" | sed 's/ //g' | sed 's/-//g' | sed 's/://g' | cut -c1-6`
 
    result2="$(grep -i -A 1 ^$MAC2 ./oui.txt)";
 
    if [ "$result2" ]; then
        echo -e "\tПроизводитель: `echo "$result2" | cut -f 3`"
        ismobile=`echo $result2 | grep -i -E 'Olivetti|Sony|Mobile|Apple|Samsung|HUAWEI|Motorola|TCT|LG|Ragentek|Lenovo|Shenzhen|Intel|Xiaomi|zte'`
        warning=`echo $result2 | grep -i -E 'ALFA|Intel'`
        if [ "$ismobile" ]; then
            echo -e "\t\033[0;33mВероятно, это мобильное устройство\e[0m"
        fi
        if [ "$warning" ]; then
            echo -e "\t\033[0;31;5;7mУстройство может поддерживать режим монитора\e[0m"
        fi
    else
        echo -e "\tПроизводитель: \e[3mИнформация не найдена в базе данных.\e[0m"
    fi
 
    probed=`echo $line2 | cut -d ',' -f 7`
 
    if [ "`echo $probed | grep -E [A-Za-z0-9_\\-]+`" ]; then
        echo -e "\tИскал сети: $probed"
    fi         
 
done < <(grep -E '(not associated)' $FILE)
