#!/bin/zsh

red='\e[0;31m'
black='\e[0;30m'     
cyan='\e[1;36m'
purple='\e[0;35m'
green='\e[0;32m'
yellow='\e[0;33m'
lightBlue='\e[0;34m'
NC='\e[0m' # No Color

if [ $# -ne 1 ]
	then
	echo "Please give the function a website"
	exit
fi

outputfile=/tmp/network_connection_test.dat

function removeOutputFile() {
	if [ -f $outputfile ]
	then
		rm $outputfile
	fi
}

function verifyConnection() {
	var=$(ping -c 1 $site | wc -l)
	if [ $var -eq 0 ]
		then
		echo "Cannot connect to $site"
		echo -e "${red}Exiting without testing anything${NC}"
		exit
	fi
	echo "${yellow}Connection to $site verified${NC}"
}

function getPackagePercentLossList() {
	 var=$(grep 'packets transmitted,' $outputfile | awk '{print $7}' | sed 's/%//g' | tr '\n' ' ' | sed 's/[ \t]*$//' | sed 's/ / + /g' | bc -l)
	 echo $var
}

function getAveragePacketLoss() {
	sum=$(grep 'packets transmitted,' $outputfile | awk '{print $7}' | sed 's/%//g' | tr '\n' ' ' | sed 's/[ \t]*$//' | sed 's/ / + /g' | bc -l)
	average=$(echo "$sum / $numRounds" | bc -l)
	printf "%0.2f\n" $average
}

function getStdDevPacketLoss() {

}

function getAverageConnectionTime() {
	sum=$(grep 'bytes from' $outputfile | awk '{print $7}' | sed 's/%//g' | sed 's/time=//g' | tr '\n' ' ' | sed 's/[ \t]*$//' | sed 's/ / + /g' | bc -l)
	average=$(echo "$sum / ($numRounds * $pingCountPerRound) " | bc -l)
	printf "%0.2f\n" $average
}

removeOutputFile
site=$1
numRounds=10
pingCountPerRound=3

echo "${cyan}Analyzing the network connection to $site${NC}"

verifyConnection

for ((i=1;i<=$numRounds;i++))
do
	echo "Ping round $i of $numRounds"
	ping -c $pingCountPerRound $site >> $outputfile
done

echo "${cyan}The average packet loss is $(getAveragePacketLoss)%${NC}"
echo "${cyan}The average connection time is $(getAverageConnectionTime) ms${NC}"
#removeOutputFile

echo -e "${green}Exiting normally${NC}"
exit
