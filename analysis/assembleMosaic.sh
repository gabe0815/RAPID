#!/bin/bash

#assemble mosaic from file list

#IMGLIST=$(while read i; do FILE=$(echo $i | cut -f1); echo $FILE; done < $1)
#IMGLIST=$(while read i; do FILE=$(echo "$i" | cut -f1); DIRNAME=$(dirname $FILE); TIME=$(echo "$i"|cut -f3); AFTER=$(find $DIRNAME -name "*after.jpg"); printf " -label" $TIME $AFTER; done < $1)
IMGLIST=$(while read i; do FILE=$( echo "$i" | cut -f1); DIRNAME=$(dirname $FILE); TIME=$(echo "$i"|cut -f3); AFTER=$(find $DIRNAME -name "*after.jpg"); echo "-label" $TIME $AFTER; done < $1)
montage $IMGLIST -tile 5x -geometry 307x230+2+2 montage.jpg

#echo $IMGLIST
