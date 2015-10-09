#!/bin/bash

/home/user/applications/RAPID/ptpcam/ptpcam --dev=$1 --chdk="upload /home/user/applications/RAPID/ptpcam/psmag01.lua A/CHDK/SCRIPTS/psmag01.lua"

sleep 2

/home/user/applications/RAPID/ptpcam/ptpcam --dev=$1 --chdk="upload /home/user/applications/RAPID/ptpcam/setfoc.lua A/CHDK/SCRIPTS/setfoc.lua"

sleep 2

