#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
#. ~/RAPID/analysis/config.sh
IMAGEPATH=/media/imagesets04/20160311_vibassay_set5/dl1460297184_5_3_3

WIDTH=3072
HEIGHT=2304
COLUMNS=4
SCALE=0.25

rm $IMAGEPATH/tracklength.txt 

#compile list of all tracklength
for i in $(find $IMAGEPATH -name "*overlay.jpg_tracklength.jpg"); 
do 
    sampleID=$(head -n1 $(dirname $i)/sampleID.txt)
    printf  "$i\t$sampleID\n"
done >> $IMAGEPATH"/tracklength.txt"

#sort and compile 
