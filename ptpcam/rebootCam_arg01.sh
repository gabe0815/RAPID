#!/bin/bash

/home/user/applications/RAPID/ptpcam/ptpcam --dev=$1 --chdk="lua sleep(2000) reboot()"
sleep 4

