#!/bin/bash

#TESTSET=/media/imagesets04/20160311_vibassay_set5/IFP187_28_folders.txt
#TESTSETLIST=/media/imagesets04/20160311_vibassay_set5/IFP187_28_sorted.txt
#TESTSET=/media/imagesets04/20160311_vibassay_set5/IFP199_12_folders.txt
#TESTSETLIST=/media/imagesets04/20160311_vibassay_set5/IFP199_12_sorted.txt
TESTSET=/media/imagesets04/20151203_vibassay_set2/IFP143_60_folders.txt
TESTSETLIST=/media/imagesets04/20151203_vibassay_set2/IFP143_60_sorted.txt

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
    > $filepath'_mosaic_coordinates.txt'
    count=0 
    while read i;
		do
            img=$( echo "$i" | cut -f1); 
            imglist=$(echo $imglist $img)
            xcoord=$(echo $count%$COLUMNS | bc)
            ycoord=$(echo $count/$COLUMNS | bc)
            imgPath=$(echo $img | cut -d"/" -f1-5)
            echo $imgPath','$xcoord','$ycoord 
            echo $imgPath','$xcoord','$ycoord >> $filepath'_mosaic_coordinates.txt'
            count=$(echo "$count +1" | bc)

    
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
