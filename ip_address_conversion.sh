#!/bin/bash
function INET_NTOA() { 
    local IFS=. num quad ip e
    num=$1
    for e in 3 2 1
    do
        (( quad = 256 ** e))
        (( ip[3-e] = num / quad ))
        (( num = num % quad ))
    done
    ip[3]=$num
    echo "${ip[*]}"
}

function INET_ATON () {
    local IFS=. ip num e
    ip=($1)
    for e in 3 2 1
    do
        (( num += ip[3-e] * 256 ** e ))
    done
    (( num += ip[3] ))
    echo "$num"
}

function getDotCount() {
    ip=$1
    echo $ip | sed 's/[^.]//g' | awk '{print length}'
}

function hasBadOctects() {
    local IFS=.
    declare -a start=($1)
    declare -a end=($2)

    if [[ start[0] -gt 255 || start[1] -gt 255 || start[2] -gt 255  || start[3] -gt 255 ]]
        then
        echo "true"
        exit 1
    fi

    if [[ end[0] -gt 255 || end[1] -gt 255 || end[2] -gt 255  || end[3] -gt 255 ]]
        then
        echo "true"
        exit 1
    fi

    unset -f start, end
    echo "false"
}

if [ "$#" -ne 2 ]
    then
    echo "Please give me a starting and and ending IP address...the order doesn't matter"
    echo "Example usage..."
    echo "ip_address_conversion.sh <192.168.1.100> <192.168.1.115>"
    exit 1
fi

startIP=$1
endIP=$2

octectCheck=$(hasBadOctects $startIP $endIP)

if [ $octectCheck = "true" ]
    then
    echo "Bad octects over 255"
    exit 1
fi

startDotCount=$(getDotCount $startIP)
if [ $startDotCount -ne 3 ]
    then
    startDotCount=$(($startDotCount+1)) #add 1 because this is the delimiter, not the number of fields
    echo "Bad Starting Address: wrong number of octects, should be 4 but is $startDotCount"
    exit 1
fi

endDotCount=$(getDotCount $endIP)
if [ $endDotCount -ne 3 ]
    then
    endDotCount=$(($endDotCount+1)) #add 1 because this is the delimiter, not the number of fields
    echo "Bad Ending Address: wrong number of octects, should be 4 but is $endDotCount"
    exit 1
fi

startNum=$(INET_ATON $startIP)
endNum=$(INET_ATON $endIP)

if [ $startNum -gt $endNum ]
    then
    temp=$startNum
    startNum=$endNum
    endNum=$temp
fi

for ((ip=$startNum;$ip<=$endNum;ip++))
do
    INET_NTOA $ip
done

exit 0
