#!/bin/bash

. ~/applications/RAPID/analysis/config.sh

DIR=$(echo $IMAGEPATH | cut -d "/" -f4)
cd $IMAGEPATH
#rsync -aP --bwlimit=1000 --exclude='*.AVI' --exclude="*.JPG" --include='*' ./ jhench@ws522988.dyn.uhbs.ch:/mnt/4TBraid04/imagesets04/20160311_vibassay_set5/
rsync -aP --bwlimit=1000 --exclude='*.AVI' --exclude="*.JPG" --include='*' ./ jhench@ws522988.dyn.uhbs.ch:/mnt/4TBraid04/imagesets04/"$DIR"
