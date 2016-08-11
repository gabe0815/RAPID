#!/bin/bash

#$IMAGEPATH is stored globally for all scripts in config.sh
. config.sh

rm $IMAGEPATH"/temp.log"

find $IMAGEPATH -name "temperature.txt" -exec ~/applications/RAPID/temperature/parseTemp.sh {} >> $IMAGEPATH"/temp.log" \;

