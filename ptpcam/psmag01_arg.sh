#!/bin/bash

#usage: ./psmag01_arg.sh [cameraBus] [targetDir] [sampleID] [timestamp] [AssayVersion] [camera serial] [physical camera position]
#furthermore it will read the temperature from a file and copy it in to the directory


PTPCAM=/home/user/applications/RAPID/ptpcam/ptpcam

touch /tmp/busy_$1.lck
touch /tmp/busy_rec_$1.lck

$PTPCAM --dev=$1 --chdk="lua loadfile(\"A/CHDK/SCRIPTS/psmag01.lua\")()"

sleep 90

rm /tmp/busy_rec_$1.lck

mkdir -p $2
cd $2

touch download.lck

$PTPCAM --dev=$1 -G

rm download.lck

if [ -f PS.FI2 ]; then 
    rm PS.FI2
fi

$PTPCAM --dev=$1 -D

echo "$3" > sampleID.txt

echo "$4" > timestamp.txt

echo "$5" > version.txt
echo "$6" > camera.txt
echo "$7" >> camera.txt

#temperature logging
if [ -f /tmp/temperature.log ]
then
	cp /tmp/temperature.log temperature.txt
else 
	echo "-1,-1" > temperature.txt
fi


rm /tmp/busy_$1.lck
