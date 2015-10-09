#!/bin/bash

#usage: ./setfoc_arg.sh [cameraBus]

PTPCAM=/home/user/applications/RAPID/ptpcam/ptpcam

touch /tmp/busy_$1.lck

$PTPCAM --dev=$1 --chdk="lua loadfile(\"A/CHDK/SCRIPTS/setfoc.lua\")()"

sleep 3

rm /tmp/busy_$1.lck
