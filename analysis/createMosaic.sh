#!/bin/bash

#function assembleMosaic {
	
#}

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
. ~/applications/RAPID/analysis/config.sh

#get sample list 
if [ -f $IMAGEPATH/sampleIDs.txt ]; then
    rm $IMAGEPATH/sampleIDs.txt 
fi


#exclude all sets that have been recorded before 2015-12-06 17:30:00 as until then, the assay was not working properly.
#include only sets that have been analysed
#to calculate minutes, use $(echo 'scale=$TIMEDIFF/3600' | bc -l)

#hence $BADTIME is the lower limit
BADTIME=$(date --date="2015-12-06 17:30:00" +%s)

for i in $(find $IMAGEPATH -name "sampleID.txt"); 
do 
	DIRNAME=$(dirname $i)
	TIMESTAMP=$(cat $DIRNAME"/timestamp.txt")
	TIMEOFBIRTH=$(tail -n1 $i)
	SAMPLEID=$(head -n1 $i)

	if [ $TIMESTAMP -ge $BADTIME ] && [ -f $DIRNAME"/imgseries_h264.AVI_parameters.txt" ]; then
#		echo -en $i'\t'; head -n1 $i; echo -en "\t $((TIMESTAMP-TIMEOFBIRTH)) 
		printf "$i\t$SAMPLEID\t$((TIMESTAMP-TIMEOFBIRTH))\n"	
	fi

done >> $IMAGEPATH"/sampleIDs.txt"


#get unique sampleID
cut -f2 $IMAGEPATH"/sampleIDs.txt" | sort | uniq >> $IMAGEPATH"/sampleIDs_uniqe.txt"

#compile list for each sampleID

#while read j; do grep "\<$j\>" $IMAGEPATH"/sampleIDs.txt" > $IMAGEPATH"/sample_$j.txt"; assembleMosaic $IMAGEPATH"/sample_$j.txt"; done < $IMAGEPATH"/sampleIDs_uniqe.txt"
while read j; do grep "\<$j\>" $IMAGEPATH"/sampleIDs.txt" > $IMAGEPATH"/sample_$j.txt"; done < $IMAGEPATH"/sampleIDs_uniqe.txt"

#create a mosaic


