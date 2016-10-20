#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
. ~/applications/RAPID/analysis/config.sh
#IMAGEPATH=/mnt/4TBraid04/imagesets04/20161012_testset_V12


#functions
function assembleMosaic {
	WIDTH=3072
	HEIGHT=2304
	COLUMNS=4
	SCALE=0.25
	tileWidth=$(echo "$WIDTH * $SCALE / 1" | bc)    
	tileHeight=$(echo "$HEIGHT * $SCALE /1" | bc)

    imglist=""
    filepath="${1%.*}"
  	filename=$(basename "$1")
	sampleID="${filename%.*}"

    searchStrings=("before" "after") 	# is used in "find" command
	sets=("before" "after") 			#will used in path name of output
	
	#loop through array with index, so we can refer to both array's elements
	len=${#sets[@]}
	for (( k=0; k<${len}; k++ ));
	do
        > $filepath'_'${sets[$k]}'_mosaic_coordinates.txt'
        count=0
        imglist=""
        while read i;
		    do
                #echo ${searchStrings[$k]}
                imgPath=$(find $(dirname $i) -maxdepth 2 -name "imgseries_h264.AVI_2fps.AVI_${searchStrings[$k]}_overlay.jpg_tracklength.jpg") #imgseries_h264.AVI_2fps.AVI_before_overlay.jpg_tracklength.jpg
                if [ ! -f "$imgPath" ]
                then
                    echo "couldn't find image" 
                    continue
                else 
                    echo "found $imgPath"
                fi

			    time=$(echo "$i"|cut -f2); 
			    hours=$(echo "scale=2; $time/3600" | bc -l ); 
                imglist=$(echo $imglist "-label" $hours"h" $imgPath)
                #calculate coorinates for censoring file
                xcoord=$(echo $count%$COLUMNS | bc)
                ycoord=$(echo $count/$COLUMNS | bc)
                #echo $imgPath','$xcoord','$ycoord 
                echo $imgPath','$xcoord','$ycoord >> $filepath'_'${sets[$k]}'_mosaic_coordinates.txt'
                count=$(echo "$count +1" | bc)
        done < $1
	    #echo "assembling $1..."
        montage -pointsize 35 $imglist -tile "$COLUMNS"x -geometry $tileWidth"x"$tileHeight"+0+0" -title $sampleID" "${sets[$k]} $filepath'_'${sets[$k]}'_montage_tracklength.jpg'
    done

    
}

function createHTML {
	
	#variables within functions are global, as long as the function has been called
	
	HTML=$IMAGEPATH"/after_tracklength_overview.html"

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
		FILE=$(find $IMAGEPATH -name "*_"$i"_*after_tracklength.jpg")
		#echo $FILE	
		echo "<a href=\"$FILE\">$i</a><br>" >> $HTML
	done < $IMAGEPATH"/sampleIDs_unique.txt"

	#write footer to the file
	echo "
	</body>
	</html>" >> $HTML

}

###################### main program starts here ###########################

export -f assembleMosaic

>$IMAGEPATH/tracklength.txt
>$IMAGEPATH/mosaicList.txt
>$IMAGEPATH/sampleIDs_unique.txt

#compile list of all tracklength
for i in $(find $IMAGEPATH -name "sampleID.txt")
do 
    dirName=$(dirname $i)
	timestamp=$(cat $dirName"/timestamp.txt")
	timeOfBirth=$(tail -n1 $i)
	sampleID=$(head -n1 $i)
    printf  "$i\t$((timestamp-timeOfBirth))\t$sampleID\n" >> $IMAGEPATH"/tracklength.txt"
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

parallel -j 8 -a $IMAGEPATH"/mosaicList.txt" assembleMosaic

#createHTML

#remove all temp files	
rm $IMAGEPATH/sample_*[0-9].txt
rm $IMAGEPATH/*sorted.txt
