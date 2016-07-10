#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
#. ~/RAPID/analysis/config.sh
IMAGEPATH=/media/imagesets04/20160311_vibassay_set5

WIDTH=3072
HEIGHT=2304
COLUMNS=4
SCALE=0.25

if [ -f $IMAGEPATH/tracklength.txt ]; then
    rm $IMAGEPATH/tracklength.txt
fi
 

#compile list of all tracklength
for i in $(find $IMAGEPATH -name "*overlay.jpg_tracklength.jpg"); 
do 
    sampleID=$(head -n1 $(dirname $i)/sampleID.txt)
    timestamp=$(head -n1 $(dirname $i)/timestamp.txt)
    printf  "$i\t$timestamp\t$sampleID\n" >> $IMAGEPATH"/tracklength.txt"
done 

#sort and compile 
