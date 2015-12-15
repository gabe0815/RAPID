#!/bin/bash

#create a cron job which runs this script every hour. NOTE: only one instance of this script will run at a given time due to the pid file lock. The pid fil lock part was copied from here:
#http://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/

#$IMAGEPATH is stored globally for all scripts in config.sh
. ~/applications/RAPID/analysis/config.sh


PIDANALYSIS=~/analysis.pid
PIDFILE=~/conversion.pid

#make shure only conversion or analysis is running at the given moment, otherwise the load is too high and might cause a crash
if [ -f $PIDANALYSIS ]
then
   echo "analysis script running"
   exit 1
fi

if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "Process already running"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 1
  fi
fi

cd $IMAGEPATH

FILES=$(find ./ -name timestamp.txt)
for file in $FILES
do
		
	parentDir=`dirname $file`
	outfile=$parentDir"/imgseries_h264.AVI"
	timestampfile=$parentDir"/timestamp.txt"
	metadatafile=$outfile"_metadata.txt"

	if [ -f $parentDir"/download.lck" ]
	then
		continue
	fi
	
	if [ -f $parentDir"/IMG_0001.JPG" ] 
	then
		rm $parentDir"/IMG_0001.JPG" #delete first image as it is allways too bright for reasons unknown
	fi
	

	if [ ! -f $outfile ]
	then
    		echo "avconv is converting image series in "$dirname
		avconv -f image2 -i `echo $parentDir"/IMG_%04d.JPG"` -qscale 0 -vcodec libx264 -an $outfile
		echo "exiv2 is extracting metadata from image series in "$parentDir
		exiv2 `echo $parentDir"/IMG_????.JPG"` > $metadatafile
		echo "deleting original JPG files"
		rm `echo $parentDir"/IMG_????.JPG"`
		echo "done"
		if [ -f $metadatafile ]
		then
			echo "exctracting timestamps"
			grep -a timestamp $metadatafile | cut -d " " -f 5,6 | sed "s/:/-/; s/:/-/"  > $metadatafile"_tmp.txt"
    			while read j; do date --date="$j" +%s; done < $metadatafile"_tmp.txt" > $metadatafile"_extract.txt"
      			rm $metadatafile"_tmp.txt"
		fi

	else 
		echo "$outfile exists, skipping..."
	fi


done
rm $PIDFILE



