#!/bin/zsh

red='\e[0;31m'
black='\e[0;30m'     
cyan='\e[1;36m'
purple='\e[0;35m'
green='\e[0;32m'
yellow='\e[0;33m'
lightBlue='\e[0;34m'
NC='\e[0m' # No Color

rootz=$(pwd)
count=1
spacer="   "
globalList=""

if [ $# -lt 1 ]
	then
	echo "Please give the function a jsp file"
	exit
fi

if [ ! -f $1 ]
	then
	echo "The file $1 does not exist"
	exit
fi

function getCurrentSpacer() {
	num=$1 #this should be the variable count
	line=$spacer
	for ((i=2;i<=$num;i++))
	do
		line="${line}${spacer}"
	done
	echo $line
}

function getFullFilePath() {
	name=$(basename $1)
	var=$(find $rootz -type f -name $name | grep $name)
	echo $var
}

function getNumBeanShells() {
	var=$(grep beanShell $1 | awk -F"value" '{print $2}' | awk -F"alt" '{print $1}' | cut -d'/' -f1 | sed 's/-//g' | sed 's/,/ /g' | sed 's/beanShell://g' | sed 's/>//g' | sed 's/{//g' | sed 's/}//g' | sed 's/=//g' | sed 's/"//g' | sed 's/\$//g' | sed 's/script://g' | sed "s/'//g" | tr " " "\n" | grep "^[a-z]" | sort -u | sed 's/^[ \t]*//' | sort -u | wc -l | sed 's/^[ \t]*//')
	echo $var
}

function getBeanShells() {
	var=$(grep beanShell $1 | awk -F"value" '{print $2}' | awk -F"alt" '{print $1}' | cut -d'/' -f1 | sed 's/-//g' | sed 's/,/ /g' | sed 's/beanShell://g' | sed 's/>//g' | sed 's/{//g' | sed 's/}//g' | sed 's/=//g' | sed 's/"//g' | sed 's/\$//g' | sed 's/script://g' | sed "s/'//g" | tr " " "\n" | grep "^[a-z]" | sort -u | sed 's/^[ \t]*//' | sed -e 's/^M//')
	echo $var
}

function getNumJspFiles() {
	var=$(grep "jsp:include" $1 | cut -d'"' -f2 | cut -d'?' -f1 | grep "jsp" | sed '/</d' | cut -d"'" -f2 | sort -u | wc -l | sed 's/^[ \t]*//')
	echo $var
}

function getJspFiles() {
	var=$(grep "jsp:include" $1 | cut -d'"' -f2 | cut -d'?' -f1 | grep "jsp" | sed '/</d' | cut -d"'" -f2 | sort -u | sed '/,/d' | sed -e 's/^M//')
	echo $var
}

function removeRightDirectory() {
	var=$1
	echo ${var%/*}
}

function removeLeftDirectory() {
	var=$1
	echo $var | cut -d'/' -f2-
}

function removeLeftDirectorySlash() {
	var=$1 
	echo $var | sed 's/^\///g'
}

function printBeanShellsNoIndent() {
		local beanFile=$1
		local localSpacer=$2
		#echo "looking for beanshells in $1"
		numBeanShells=$(getNumBeanShells $beanFile)
		if [ $numBeanShells -ge 1 ]
			then
			beanShellList=$(getBeanShells $beanFile)
			for ((n=1;$n<=$numBeanShells;n++))
			do
				beanShellFileName=$(echo $beanShellList | head -$n | tail -1)
				echo "${yellow}$localSpacer.$n${NC} $beanShellFileName.bsh"
			done
		fi
}

function printBeanShells() {
		local beanFile=$1
		local localSpacer=${spacer}${spacer}$2
		#echo "looking for beanshells in $1"
		local numBeanShells=$(getNumBeanShells $beanFile)
		if [ $numBeanShells -ge 1 ]
			then
			beanShellList=$(getBeanShells $beanFile)
			for ((n=1;$n<=$numBeanShells;n++))
			do
				beanShellFileName=$(echo $beanShellList | head -$n | tail -1)
				echo "${yellow}$localSpacer.$n${NC} $beanShellFileName.bsh"
			done
		fi
}

function printFileInfo() {
	local tempPathFile1=$1
	local localDirectory1=$(dirname $tempPathFile1)
	local localFile1=$(basename $tempPathFile1)
	if [ $(getNumJspFiles $1) -ge 1 ]
		then
			local tempSpacer="${spacer}$2"
			list1=$(getJspFiles $tempPathFile1) 
			#cachedNum = $(getNumJspFiles $localDirectory1/$localFile1)
			#echo "${red}The list is  $list${NC}"
			for ((k=1;k<=$(getNumJspFiles $tempPathFile1);k++))
			do
				local cacheK=$k
				#echo "Index k is $k out of $(getNumJspFiles $tempPathFile1)"
				local printLocalDirectory1=$localDirectory1
				local tempPathFile2=$(echo $list1 | head -$k | tail -1)
				local localDirectory2=$(dirname $tempPathFile2)
				local localFile2=$(basename $tempPathFile2)
				if [ ${localDirectory2:0:3} = "../" ]
					then
					#echo "****found an up directory"
					local localDirectory2=$(removeLeftDirectory $localDirectory2)
					local printLocalDirectory1=$(removeRightDirectory $printLocalDirectory1)
				elif [ ${localDirectory2:0:1} = "." ]
					then
					#echo "****found a current directory dir"
					#localDirectory1=$(echo $localDirectory1 | sed 's/\.\///g')
				elif [ ${localDirectory2:0:1} = "/" ]
					then
					#echo "we are using an absolute path within the project repo...make it work"
					printLocalDirectory2=$(removeLeftDirectorySlash $localDirectory2)
				fi

				if [ $localDirectory2 = '.' ]
					then
					#echo "Printing a local directory"
					#echo "DEBUG:${spacer}$tempSpacer.$k $localDirectory2  SEPERATE $localFile2"
					#echo "DEBUG:${spacer}$tempSpacer.$k Going up: $localDirectory1 SEPERATE $localFile1"
					if [ ! -f $printLocalDirectory1/$localFile2 ]
						then
						echo -e "${red}${spacer}$tempSpacer.$k${NC}${red}$printLocalDirectory1/$localFile2 does not exist!${NC}"
						break;
					fi
					if [ $(getNumJspFiles $printLocalDirectory1/$localFile2) -ge 1 ]
						then
						#echo "${spacer}$tempSpacer.$k ***Found more hereA"
						local cachedList=$list1
						local cachedIndex=$k
						local cachePrintLocalDirectory1=$printLocalDirectory1
						local cacheLocalFile2=$localFile2
						#echo "${red}The list is  $list1${NC}"
						#echo "The index k is $k${NC}"
						echo -e "${purple}${spacer}$tempSpacer.$k${NC} $printLocalDirectory1/$localFile2 ${purple}*more files${NC}"
						printFileInfo "$printLocalDirectory1/$localFile2" "${spacer}$tempSpacer.$k"
						printBeanShells "$printLocalDirectory1/$localFile2" "${spacer}$tempSpacer.$k"
						list1=$cachedList
						#k=$cachedIndex
						localFile2=$cacheLocalFile2
						printLocalDirectory1=$cachePrintLocalDirectory1
						#echo "${cyan}The cached list is $cachedList${NC}"
						#echo "${cyan}The cached index is $cachedIndex${NC}"
					else
						echo -e "${purple}${spacer}$tempSpacer.$k${NC} $printLocalDirectory1/$localFile2"
						local cachedList=$list1
						local cachedIndex=$k
						local cachePrintLocalDirectory1=$printLocalDirectory1
						local cacheLocalFile2=$localFile2
						printBeanShells "$printLocalDirectory1/$localFile2" "${spacer}$tempSpacer.$k"
						list1=$cachedList
						k=$cachedIndex
						localFile2=$cacheLocalFile2
						printLocalDirectory1=$cachePrintLocalDirectory1
					fi
				elif [ ${localDirectory2:0:1} = "/" ]
					then
					#echo "Printing an repo based absolute path"
					if [ $(getNumJspFiles $directory/$localDirectory2/$localFile2) -ge 1 ]
						then
						#echo "${spacer}$tempSpacer.$k ***Found more hereB"
						#digIntoJspFile2 "$directory/$localDirectory2/$localFile2" "${spacer}${spacer}$tempSpacer.$k-"
						echo -e "${purple}${spacer}$tempSpacer.$k${NC} $directory/$localDirectory2/$localFile2 ${purple}*more files${NC}"
						local cachedList=$list1
						local cachedIndex=$k
						local cachePrintLocalDirectory1=$printLocalDirectory1
						local cacheLocalFile2=$localFile2
						printFileInfo "$directory/$localDirectory2/$localFile2" "${spacer}$tempSpacer.$k"
						printBeanShells "$directory/$localDirectory2/$localFile2" "${spacer}${spacer}$tempSpacer.$k"
						#echo "${red}The list is  $list1${NC}"
						#echo "${cyan}The cached list is $cachedList${NC}"
						#echo "The index k is $k${NC}"
						#echo "The cached index is $cachedIndex${NC}"
						list1=$cachedList
						k=$cachedIndex
					else
						echo -e "${purple}${spacer}$tempSpacer.$k${NC} $directory/$localDirectory2/$localFile2"
						local cachedList=$list1
						local cachedIndex=$k
						local cachePrintLocalDirectory1=$printLocalDirectory1
						local cacheLocalFile2=$localFile2
						printBeanShells "$directory/$localDirectory2/$localFile2" "${spacer}$tempSpacer.$k"
						list1=$cachedList
						k=$cachedIndex
					fi
				else 
					#echo "Printing a relative directory"
					#echo "DEBUG:${spacer}$tempSpacer.$k $localDirectory2  SEPERATE $localFile2"
					#echo "DEBUG:${spacer}$tempSpacer.$k Going up: $printLocalDirectory1 SEPERATE $localFile1"
					if [ $(getNumJspFiles $printLocalDirectory1/$localDirectory2/$localFile2) -ge 1 ]
						then
						#echo "${spacer}$tempSpacer.$k ***Found more hereC"
						local cachedList=$list1
						local cachedIndex=$k
						local cachePrintLocalDirectory1=$printLocalDirectory1
						local cacheLocalFile2=$localFile2
						#digIntoJspFile2 "$printLocalDirectory1/$localDirectory2/$localFile2" "${spacer}${spacer}$tempSpacer.$k-"
						echo -e "${purple}${spacer}$tempSpacer.$k${NC} $printLocalDirectory1/$localDirectory2/$localFile2 ${purple}*more files${NC}"
						printFileInfo "$printLocalDirectory1/$localDirectory2/$localFile2" "${spacer}$tempSpacer.$k"
						printBeanShells "$printLocalDirectory1/$localDirectory2/$localFile2" "${spacer}$tempSpacer.$k"
						#echo "${red}The list is  $list1${NC}"
						#echo "${cyan}The cached list is $cachedList${NC}"
						#echo "The index k is $k${NC}"
						#echo "The cached index is $cachedIndex"
					else
						echo -e "${purple}${spacer}$tempSpacer.$k${NC} $printLocalDirectory1/$localDirectory2/$localFile2"
						printBeanShells "$printLocalDirectory1/$localDirectory2/$localFile2" "${spacer}$tempSpacer.$k"
					fi
				fi
				#echo "Reset the index k to $cacheK out of $(getNumJspFiles $tempPathFile1)"
				k=$cacheK
			done
	fi

}

function digIntoJspFile2() {

	if [ $# -ne 2 ]
		then
		echo "The function digIntoJspFile2 requires 2 arguments...this is for dev only..remove later"
		exit
	fi

	file=$(basename $1)
	directory=$(dirname $1)
	spacerLine=$2
	givenIndex=$(echo -e "${spacerLine}${count}") #add some space so it gets pushed over

	list=$(getJspFiles $directory/$file)
	num=$(getNumJspFiles $directory/$file)

	echo "${cyan}$2The file $directory/$file contains $num jsp file references${NC}"

	if [ $num -ge 1 ]
		then
		for ((j=1;j<=$num;j++))
		do
			tempFile1=$(getJspFiles $directory/$file | head -$j | tail -1)
			if [ $(getNumJspFiles $directory/$tempFile1) -ge 1 ]
				then
				echo -e "${purple}$givenIndex.${j}${NC} $directory/$tempFile1 ${purple}*more files${NC}"
			else
				echo -e "${purple}$givenIndex.${j}${NC} $directory/$tempFile1"
			fi
			tempPathFile1=$directory/$tempFile1
			printFileInfo $tempPathFile1 $givenIndex.${j}
			printBeanShells $tempPathFile1 $givenIndex.${j}
			count=$(($count+1))
		done
	fi

	printBeanShellsNoIndent $1 "1"
}

digIntoJspFile2 $1 ""

echo "${green}Exiting normally${NC}"

exit









