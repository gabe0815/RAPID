#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
#. ~/RAPID/analysis/config.sh

#static variables
IMAGEPATH=/media/imagesets04/20160311_vibassay_set5

WIDTH=3072
HEIGHT=2304
COLUMNS=4
SCALE=0.25

#functions
function assembleMosaic {
    imglist=""
  	filename=$(basename "$1")
	sampleID="${filename%.*}"
    printf "" > $1"_mosaic_coordinates.txt"
    index=0    
    while read i;
		do
            img=$(cut -f1 $i)
            imglist=$imglist $img
            xcoord=$(index % $COLUMNS)
            ycoord=$(index/$COLUMNS)
            index=$index+1
            
    
    done < $1)
    montage $imglist -tile "$COLUMNS"x -geometry $(echo "$WIDTH"*"$SCALE"/1 | bc)x$(echo "$HEIGTH"*"$SCALE"/1 | bc) -title $sampleID $IMAGEPATH"_montage_tracklength.jpg"

    
}

# main progam starts here
if [ -f $IMAGEPATH/tracklength.txt ]; then
    rm $IMAGEPATH/tracklength.txt
fi
 

#compile list of all tracklength
for i in $(find $IMAGEPATH -name "*overlay.jpg_tracklength.jpg"); 
do 
    sampleID=$(head -n1 $(dirname $i)/sampleID.txt)
    timestamp=$(head -n1 $(dirname $i)/timestamp.txt)
    printf  "$i\t$timestamp\t$sampleID\n" >> $IMAGEPATH"/tracklength.txt"
done 

#get unique sampleID
cut -f3 $IMAGEPATH"/tracklength.txt" | sort -V | uniq >> $IMAGEPATH"/sampleIDs_unique.txt"

while read j; 
	do 
	grep "\<$j\>" $IMAGEPATH"/tracklength.txt" > $IMAGEPATH"/sample_$j.txt"; 
	sort -k2 -n $IMAGEPATH"/sample_$j.txt" > $IMAGEPATH"/sample_"$j"_sorted.txt"; 
	assembleMosaic $IMAGEPATH"/sample_"$j"_sorted.txt"; 
	#remove all temp files	
	rm $IMAGEPATH"/sample_"$j"_sorted.txt" $IMAGEPATH"/sample_$j.txt"; 
done < $IMAGEPATH"/sampleIDs_unique.txt"

