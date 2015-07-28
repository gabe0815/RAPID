#!/bin/bash

#usage: ./deleteImages_arg.sh [cameraBus]

PTPCAM=/home/user/applications/RAPID/ptpcam/ptpcam
$PTPCAM --dev=$1 -D
