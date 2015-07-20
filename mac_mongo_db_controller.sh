#!/bin/bash

BREW=/usr/local/bin/

LOCK_FILE=/data/db/mongod.lock

function printHelp() {
	echo "Function usage "
	echo "--------"
	echo "mongo_controller.sh <start|stop|hardKill|status>"
	echo "The hardKill option explicity finds the PID and kills the process"
	exit 1
}

function startMongo() {
	$BREW/mongod --fork --logpath /data/log/mongodb.log 2>> /data/log/error.out 1>> /data/log/std.out
}

function killPid() {
	kill $@ || {echo "Unable to kill PID $@"}
}

function removeLockFile() {
	if [ -f $LOCK_FILE ]
		then
		echo "Removing $LOCK_FILE..."
		rm -v $LOCK_FILE
		echo "Done!"
	fi
}

function showMongoStatus() {
	if [ -f $LOCK_FILE ]
			then
			echo "A Mongo isntance is running with PID `cat $LOCK_FILE` and is tracked with the Lock file $LOCK_FILE"
		else
			echo "No Mongo instances are running that are being tracked with the Lock file $LOCK_FILE"
	fi
	declare -i mongo_pid
	mongo_pid=$(ps aux | egrep -i mongod | grep -v grep | awk '{print $2}')
	if [ $mongo_pid -ne 0 ]
		then
		echo "There is a Mongo instance running with PID $mongo_pid"
	fi
}

function cleanupExistingMongoInstances() {
	if [ -f $LOCK_FILE ]
		then
		declare -i mpid
		check=$(cat $LOCK_FILE | wc -l)
		if [ $check -gt 1 ]
			then
			echo "*******WARNING*******"
			echo "There are multiple Mongo PIDs executing: `cat $LOCK_FILE`"
		fi
		mpid=$(cat $LOCK_FILE)
		echo "Stopping Mongo instance with PID $mpid"
		killPid $mpid
		removeLockFile
	else
		echo "Hmmmm the Mongo PID Lock file is not here ... maybe multiple processes are starting/stopping Mongo"
	fi
}

case "$1" in
	start)
		if [ -f $LOCK_FILE ]
			then
			echo "There is a stale Mongo PID file here ..."
			cleanupExistingMongoInstances
		fi
		startMongo
		mpid=$(cat $LOCK_FILE)
		echo "The Mongo PID is $mpid"
		;;
	stop)
		cleanupExistingMongoInstances
		;;
	status)
		showMongoStatus
		;;
	hardKill)
		declare -i mongo_pid
		mongo_pid=$(ps aux | egrep -i mongod | grep -v grep | awk '{print $2}')
		if [ $mongo_pid -eq 0 ]
			then
			echo "There are no Mongo processes running"
			removeLockFile
			exit 0
		fi
		echo "Performing a hardKill on Mongo instance with PID $mongo_pid"
		killPid $mongo_pid
		removeLockFile
		;;
	*)
		echo "Unknown option: $1"
		printHelp
		;;
esac

exit 0
