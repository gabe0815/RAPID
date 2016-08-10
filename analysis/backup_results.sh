#!/bin/bash

. ~/applications/RAPID/analysis/config.sh

cd $IMAGEPATH
#rsync -aP --bwlimit=1000 --exclude='*.AVI' --exclude="*.JPG" --include='*' ./ jhench@ws522988.dyn.uhbs.ch:/mnt/4TBraid04/imagesets04/20160311_vibassay_set5/
rsync -aP --bwlimit=1000 --exclude='*.AVI' --exclude="*.JPG" --include='*' ./ jhench@ws522988.dyn.uhbs.ch:/mnt/4TBraid04/imagesets04/20160720_vibassay_set9
