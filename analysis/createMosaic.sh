#!/bin/bash
#bla

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
. ~/RAPID/analysis/config.sh


WIDTH=3072
HEIGHT=2304
COLUMNS=4
SCALE=0.25

############ helper functions ##############
function assembleMosaic {

	FILEPATH="${1%.*}"
  	FILENAME=$(basename "$1")
	SAMPLEID="${FILENAME%.*}"
#	SEARCHSTRINGS=("before" "after" "combined" "_[0-9][0-9]" "overlay" "tracklength") 	# is used in "find" command
#	SETS=("before" "after" "combined" "photo" "overlay" "tracklength") 			#will used in path name of output
	SEARCHSTRINGS=("tracklength") 	# is used in "find" command
	SETS=("tracklength") 			#will used in path name of output
	
	#loop through array with index, so we can refer to both array's elements
	len=${#SETS[@]}
	for (( k=0; k<${len}; k++ ));
	do
        echo assembling $1 ...
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
		montage $IMGLIST -tile "$COLUMNS"x -geometry $(echo "$WIDTH"*"$SCALE"/1 | bc)x$(echo "$HEIGTH"*"$SCALE"/1 | bc) -title $SAMPLEID $FILEPATH"_montage_${SETS[$k]}.jpg"
        echo 'montage $IMGLIST -tile "$COLUMNS"x -geometry $(echo "$WIDTH"*"$SCALE"/1 | bc)x$(echo "$HEIGTH"*"$SCALE"/1 | bc) -title $SAMPLEID $FILEPATH"_montage_${SETS[$k]}.jpg'
	done
}


function createHTML {
	
	#variables within functions are global, as long as the function has been called
	for m in "${SETS[@]}"
		do
		
		HTML=$IMAGEPATH"/"$m"_overview.html"

		#write header to the file
		echo "<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">
		<html><head>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">
		<meta name=\"Author\" content=\"J. Hench, G. Schweighauser\">
		<title>image viewer</title>
		<base target=\"imageFrame\">
		<script>
		if(window == window.top)
		{
		var address=window.location;
		var s='<html><head><title>image viewer</title></head>'+
		'<frameset cols=\"15%,85%\" frameborder=\"4\" onload=\"return true;\" onunload=\"return true;\">' +
		'<frame src=\"'+address+'?\" name=\"indexframe\">'+
		'<frame src=\"file:///\" name=\"imageFrame\">'+
		'</frameset>'+
		'</html>';
		document.write(s)    
		}
		</script>
		</head>
		<body text=\"#000000\" bgcolor=\"#C0C0C0\" link=\"#0000FF\" vlink=\"#8154D1\" alink=\"#ED181E\">" > $HTML 

		#go through sampleIDs unique list and find montage images.
		while read i; 
			do 
			FILE=$(find $IMAGEPATH -name "*_"$i"_*"$m".jpg")
			#echo $FILE	
			echo "<a href=\"$FILE\">$i</a><br>" >> $HTML
		done < $IMAGEPATH"/sampleIDs_unique.txt"

		#write footer to the file
		echo "
		</body>
		</html>" >> $HTML
	done
}
########## main script starts here ############ 


#if [ -f $IMAGEPATH/sampleIDs.txt ]; then
#    rm $IMAGEPATH/sampleIDs.txt 
#fi

#if [ -f $IMAGEPATH"/sampleIDs_unique.txt" ]; then
#	rm $IMAGEPATH"/sampleIDs_unique.txt"
#fi


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
cut -f2 $IMAGEPATH"/sampleIDs.txt" | sort -V | uniq >> $IMAGEPATH"/sampleIDs_unique.txt"


while read j; 
	do 
	grep "\<$j\>" $IMAGEPATH"/sampleIDs.txt" > $IMAGEPATH"/sample_$j.txt"; 
	sort -k3 -n $IMAGEPATH"/sample_$j.txt" > $IMAGEPATH"/sample_"$j"_sorted.txt"; 
	assembleMosaic $IMAGEPATH"/sample_"$j"_sorted.txt"; 
	#remove all temp files	
	rm $IMAGEPATH"/sample_"$j"_sorted.txt" $IMAGEPATH"/sample_$j.txt"; 
done < $IMAGEPATH"/sampleIDs_unique.txt"

#createHTML

