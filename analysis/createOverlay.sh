#!/bin/bash

combine(){
    if [ ! -f "*overlay.jpg" ]
    then 
        path=$(dirname $1)
        photo=$(find $path -name "*_[0-9][0-9].jpg")
        ./mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/combineTrackAndPhoto.py $1 $photo    
        #echo $1 $photo
        #echo "********************"
    fi
}

export -f combine

find $1 -name "*after.jpg" | parallel combine {}
