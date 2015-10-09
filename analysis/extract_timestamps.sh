#!/bin/bash

for i in `ls`; do
	if [ ! -f $i/imgseries_h264.AVI_metadata.txt_extract.txt ]; then
		echo "exctracting timestamps"
		grep -a timestamp $i/imgseries_h264.AVI_metadata.txt | cut -d ':' -f6 >> $i/imgseries_h264.AVI_metadata.txt_extract.txt


	fi
done




