#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
. ~/applications/RAPID/analysis/config.sh

function assembleMosaic {

	FILEPATH="${1%.*}"
  	FILENAME=$(basename "$1")
	SAMPLEID="${FILENAME%.*}"
	SEARCHSTRINGS=("before" "after" "combined" "_[0-9][0-9]") 	# is used in "find" command
	SETS=("before" "after" "combined" "photo") 			#will used in path name of output
	
	#loop through array with index, so we can refer to both array's elements
	len=${#SETS[@]}
	for (( k=0; k<${len}; k++ ));
	do
		#go through list and compile input for "montage" function		
		IMGLIST=$(while read i;
			do 
				FILE=$( echo "$i" | cut -f1); 
				DIRNAME=$(dirname $FILE); 
				TIME=$(echo "$i"|cut -f3); 
				HOURS=$(echo "scale=2; $TIME/3600" | bc -l ); 
				IMAGE=$(find $DIRNAME -name "*${SEARCHSTRINGS[$k]}.jpg"); 
				#adjust contrast of "combined" image, without overwriting the original
				if [ "${SEARCHSTRINGS[$k]}" = "combined" ]; then				
					if [ ! -f $IMAGE"_normalized.jpg" ]; then
						convert $IMAGE -normalize $IMAGE"_normalized.jpg"
					fi
					IMAGE=$IMAGE"_normalized.jpg"
				fi
				echo "-label" $HOURS"h" $IMAGE; 
			done < $1)
		montage $IMGLIST -tile 5x -geometry 307x230+2+2 -title $SAMPLEID $FILEPATH"_montage_${SETS[$k]}.jpg"
	done
}


########## main script starts here ############ 


if [ -f $IMAGEPATH/sampleIDs.txt ]; then
    rm $IMAGEPATH/sampleIDs.txt 
fi


#exclude all sets that have been recorded before 2015-12-06 17:30:00 as until then, the assay was not working properly.
#include only sets that have been analysed

#$BADTIME is the lower limit
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

while read j; 
	do 
	grep "\<$j\>" $IMAGEPATH"/sampleIDs.txt" > $IMAGEPATH"/sample_$j.txt"; 
	sort -k3 -n $IMAGEPATH"/sample_$j.txt" > $IMAGEPATH"/sample_"$j"_sorted.txt"; 
	assembleMosaic $IMAGEPATH"/sample_"$j"_sorted.txt"; 
	#remove all temp files	
	rm $IMAGEPATH"/sample_"$j"_sorted.txt" $IMAGEPATH"/sample_$j.txt"; 
done < $IMAGEPATH"/sampleIDs_uniqe.txt"

