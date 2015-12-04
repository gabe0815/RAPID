#!/bin/bash

#create a cron job which runs this script every hour. NOTE: only one instance of this script will run at a given time due to the pid file lock. The pid fil lock part was copied from here:
#http://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/


PIDFILE=/home/user/conversion.pid
filePath=/mnt/4TBraid02/20151203_vibassay_set2/
#filePath=/mnt/4TBraid02/20151021_vibassay_set1/


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

cd $filePath

FILES=$(find ./ -name timestamp.txt)
for file in $FILES
do
		
	parentDir=`dirname $file`
	outfile=$parentDir"/imgseries_h264.AVI"
	timestampfile=$parentDir"/timestamp.txt"
	metadatafile=$outfile"_metadata.txt"
	qrimage=$outfile"_qrcode.jpg"
	qrtext=$outfile"_qrcode.txt"
	
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

	else 
		echo "$outfile exists, skipping..."
	fi


done
rm $PIDFILE



