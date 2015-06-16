#!/bin/bash

#/home/user/applications/ptpcam/ptpcam --chdk="lua loadfile(\"A/CHDK/SCRIPTS/phoser1m.lua\")()"

touch /tmp/busy_$1.lck
/home/user/apps/ptpcam/ptpcam_32bit --dev=$1 --chdk="lua loadfile(\"A/CHDK/SCRIPTS/psmag01.lua\")()"

sleep 90

DIR=/home/user/lens_test/`date +%s`
mkdir -p $DIR
cd $DIR 
/home/user/apps/ptpcam/ptpcam_32bit --dev=$1 -G
/home/user/apps/ptpcam/ptpcam_32bit --dev=$1 -D
rm /tmp/busy_$1.lck
