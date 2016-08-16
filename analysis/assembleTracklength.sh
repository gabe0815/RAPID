#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
. ~/RAPID/analysis/config.sh


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
            if [[ $i == *"imagesets04"* ]] # we're on the analysis computer
            then
                imgPath=$(echo $img | cut -d"/" -f1-6)
            else
                imgPath=$(echo $img | cut -d"/" -f1-5)
            fi

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

function createHTML {
	
	#variables within functions are global, as long as the function has been called
	
	HTML=$IMAGEPATH"/tracklength_overview.html"

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
		FILE=$(find $IMAGEPATH -name "*_"$i"_*tracklength.jpg")
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

parallel -j 4 -a $IMAGEPATH"/mosaicList.txt" assembleMosaic

createHTML

#remove all temp files	
rm $IMAGEPATH/sample_*[0-9].txt
rm $IMAGEPATH/*sorted.txt


