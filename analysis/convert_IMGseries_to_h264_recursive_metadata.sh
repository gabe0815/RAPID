#!/bin/bash

while [ true ]
do
	FILES=$(find ./ -name timestamp.txt)
	for file in $FILES
	do
		parentDir=`dirname $file`
		outfile=$parentDir"/imgseries_h264.AVI"
		timestampfile=$parentDir"/timestamp.txt"
		metadatafile=$outfile"_metadata.txt"
		qrimage=$outfile"_qrcode.jpg"
		qrtext=$outfile"_qrcode.txt"

		if [ ! -f $outfile ]
		then
	    		echo "avconv is converting image series in "$dirname
			avconv -f image2 -i `echo $parentDir"/IMG_%04d.JPG"` -qscale 0 -vcodec libx264 -an $outfile
			echo "exiv2 is extracting metadata from image series in "$parentDir
			exiv2 `echo $parentDir"/IMG_????.JPG"` > $metadatafile
			echo "deleting original JPG files"
			rm `echo $parentDir"/IMG_????.JPG"`
			echo "done"

		else 
			echo "$outfile exists, skipping..."
		fi
	done
	sleep 10
done
