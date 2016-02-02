#!/bin/bash
IMAGELIST=/mnt/4TBraid02/20151203_vibassay_set2/sampleIDs.txt

#use parallel to read input from sampleIDs.txt and process them in parallel as described here:
#http://www.gnu.org/software/parallel/man.html#EXAMPLE:-Use-a-table-as-input

parallel  -P 4 -a $IMAGELIST --colsep '\t'  combineTrackAndPhoto {1}


function combineTrackAndPhoto {
	PATH=$(echo "$1" | cut -d "/" -f1-5);
	TRACK=$(find $PATH -name "*after.jpg")	
	PHOTO=$(find $PATH -name "*_[0-9][0-9].jpg")
	if [[ -f $TRACK ]] && [[ -f $PHOTO ]]; then
		echo "combining images $TRACK and $PHOTO from $FOLDER"
		/home/user/Documents/RAPID/analysis/combineTrackAndPhoto.py $TRACK $PHOTO
	else
		echo "skipping ... $TRACK $PHOTO"
	fi
}
