#!/bin/bash

. ~/applications/RAPID/analysis/config.sh

DIR=$(echo $IMAGEPATH | cut -d "/" -f4)
cd $IMAGEPATH
#rsync -rtlP --bwlimit=1000 --exclude='*.AVI' --exclude="*.JPG" --include='*' ./ jhench@ws522988.dyn.uhbs.ch:/mnt/4TBraid04/imagesets04/"$DIR"
rsync -rtlP --exclude='*.AVI' --exclude="*.JPG" --include='*' ./ jhench@ws522988.dyn.uhbs.ch:/mnt/4TBraid04/imagesets04/"$DIR"
