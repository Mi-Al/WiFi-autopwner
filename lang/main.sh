#!/bin/bash
declare -A Lang
while read line; do
    key=$(echo $line | grep -Po "^(.*)(?=::.*$)")
    text=$(echo $line | grep -Po "^.*::\K(.*)$")
    Lang[$key]=$text
done <$(dirname $0)/lang/$LANGUAGE.txt