#!/bin/bash

declare -i i=0
declare -i j=0
declare -i k=0

for ((i=0;i<=7;i++))
do
    for ((j=0;j<=7;j++))
    do
        for ((k=0;k<=7;k++))
        do
            umask $i$j$k
            echo "$i$j$k && `umask -S`"
        done
    done
done

exit
