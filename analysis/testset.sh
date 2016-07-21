#!/bin/bash

TESTSET=/media/imagesets04/20160311_vibassay_set5/IFP187_28_folders.txt
TESTSETLIST=/media/imagesets04/20160311_vibassay_set5/IFP187_28_sorted.txt
#run tracklength.py
cat $TESTSET | parallel --eta -j16 python /mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/trackLength.py {}

#assemble mosaic:
WIDTH=3072
HEIGHT=2304
COLUMNS=4
SCALE=0.25

#functions
function assembleMosaic {
    imglist=""
    filepath="${1%.*}"
  	filename=$(basename "$1")
	sampleID="${filename%.*}" 
    while read i;
		do
            img=$( echo "$i" | cut -f1); 
            imglist=$(echo $imglist $img)
    
    done < $1
    montage $imglist -tile "$COLUMNS"x -geometry $(echo "$WIDTH"*"$SCALE"/1 | bc)x$(echo "$HEIGTH"*"$SCALE"/1 | bc) -title $sampleID $filepath'_montage_testset.jpg'

    
}

#delete old file
> $TESTSETLIST
while read j; 
	do 
	find $j -name "*overlay.jpg_tracklength.jpg" >> $TESTSETLIST
   	#echo $file
done < $TESTSET

assembleMosaic $TESTSETLIST
