#!/bin/bash

#create a cron job which runs this script every hour. NOTE: only one instance of this script will run at a given time due to the pid file lock. The pid fil lock part was copied from here:
#http://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/


PIDCONVERSION=/home/user/conversion.pid
PIDFILE=/home/user/analysis.pid
filePath=/mnt/4TBraid02/20151203_vibassay_set2/
#filePath=/mnt/4TBraid02/20151021_vibassay_set1/

if [ -f $PIDCONVERSION ]
then
   echo "conversion script is running, exiting ..."
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

find  $filePath -name "imgseries_h264.AVI" | parallel -P 4 "if [ ! -f {}_parameters.txt ]; then /home/user/applications/RAPID/analysis/minimumProjections05.py {}; else echo skipping {} ;fi"

rm $PIDFILE
