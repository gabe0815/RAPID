#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
. ~/applications/RAPID/analysis/config.sh


#functions
function assembleMosaic {
	WIDTH=3072
	HEIGHT=2304
	COLUMNS=4
	SCALE=0.25

    imglist=""
    filepath="${1%.*}"
  	filename=$(basename "$1")
	sampleID="${filename%.*}"
    > $filepath'_mosaic_coordinates.txt'
    count=0 
    while read i;
		do
            img=$( echo "$i" | cut -f1);
            imgPath=$(echo $img | cut -d"/" -f1-5)
            imglist=$(echo $imglist $img)
            #calculate coorinates for censoring file
            xcoord=$(echo $count%$COLUMNS | bc)
            ycoord=$(echo $count/$COLUMNS | bc)
            #echo $imgPath','$xcoord','$ycoord 
            echo $imgPath','$xcoord','$ycoord >> $filepath'_mosaic_coordinates.txt'
            count=$(echo "$count +1" | bc)
    done < $1
    montage $imglist -tile "$COLUMNS"x -geometry $(echo "$WIDTH"*"$SCALE"/1 | bc)x$(echo "$HEIGTH"*"$SCALE"/1 | bc) -title $sampleID $filepath'_montage_tracklength.jpg'

    
}

export -f assembleMosaic
# main progam starts here

>$IMAGEPATH/tracklength.txt
>$IMAGEPATH/mosaicList.txt

#compile list of all tracklength
for i in $(find $IMAGEPATH -name "*overlay.jpg_tracklength.jpg")
do 
    sampleID=$(head -n1 $(dirname $i)/sampleID.txt)
    timestamp=$(head -n1 $(dirname $i)/timestamp.txt)
    printf  "$i\t$timestamp\t$sampleID\n" >> $IMAGEPATH"/tracklength.txt"
done 

#get unique sampleID
cut -f3 $IMAGEPATH"/tracklength.txt" | sort -V | uniq >> $IMAGEPATH"/sampleIDs_unique.txt"

#compile list so that we can process sets in parallel
while read j; 
	do 
	grep "\<$j\>" $IMAGEPATH"/tracklength.txt" > $IMAGEPATH"/sample_$j.txt"
	sort -k2 -n $IMAGEPATH"/sample_$j.txt" > $IMAGEPATH"/sample_"$j"_sorted.txt" 
	echo $IMAGEPATH"/sample_"$j"_sorted.txt" >> $IMAGEPATH"/mosaicList.txt"
done < $IMAGEPATH"/sampleIDs_unique.txt"

parallel -P 4 -a $IMAGEPATH"/mosaicList.txt" assembleMosaic  

#remove all temp files	
rm $IMAGEPATH"/*_sorted.txt" $IMAGEPATH"/sample_*.txt"; 

