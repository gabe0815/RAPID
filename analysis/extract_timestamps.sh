#!/bin/bash


if [ ! -f $1_metadata.txt_extract.txt ]; then
	echo "exctracting timestamps"
	grep -a timestamp $1_metadata.txt | cut -d " " -f 5,6 | sed "s/:/-/; s/:/-/"  > $1_tmp.txt
    while read j; do date --date="$j" +%s; done < $1_tmp.txt > $1_metadata.txt_extract.txt
      rm $1_tmp.txt
fi

