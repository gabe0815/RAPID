#!/bin/bash

combine(){
    path=$(dirname $1)    
    
    if [ ! -f $path"/imgseries_h264.AVI_2fps.AVI_overlay.jpg" ]
    then 
        photo=$(find $path -name "*_[0-9][0-9].jpg")
        echo "processing: $path"
        /mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/combineTrackAndPhoto.py $1 $photo    
        #echo $1 $photo
        #echo "********************"
    else
        echo "skipping ..."    
    fi
}

export -f combine

find $1 -name "*after.jpg" | parallel combine {}
