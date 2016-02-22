#!/bin/bash

kversion=$(uname -a | cut -d' ' -f3 | cut -d'-' -f1,2)
for file in $(find /boot/ -maxdepth 1 -type f | grep -v $kversion)
do
    sudo rm -frv $file
done

