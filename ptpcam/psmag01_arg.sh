#!/bin/bash

#usage: ./psmag01_arg.sh [cameraBus] [targetDir] [sampleID] [timestamp]

PTPCAM=/home/user/applications/RAPID/ptpcam/ptpcam

touch /tmp/busy_$1.lck

$PTPCAM --dev=$1 --chdk="lua loadfile(\"A/CHDK/SCRIPTS/psmag01.lua\")()"

sleep 90

mkdir -p $2
cd $2

$PTPCAM --dev=$1 -G

if [ -f PS.FI2 ]; then 
    rm PS.FI2
fi

$PTPCAM --dev=$1 -D

`echo -e $3 > sampleID.txt`
`echo -e $4 > timestamp.txt`

rm /tmp/busy_$1.lck
