#!/bin/bash

#create a cron job which runs this script every hour. NOTE: only one instance of this script will run at a given time due to the pid file lock. The pid fil lock part was copied from here:
#http://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/

#$IMAGEPATH is stored globally for all scripts in config.sh
. ~/applications/RAPID/analysis/config.sh

PIDCONVERSION=~/conversion.pid
PIDFILE=~/analysis.pid

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

find  $IMAGEPATH -name "imgseries_h264.AVI" | parallel -P 4 "if [ ! -f {}_parameters,txt ]; then ~/applications/RAPID/analysis/minimumProjections05.py {}; else echo skipping {} ;fi"
#find  $IMAGEPATH -name "imgseries_h264.AVI" | parallel -P 8 "~/applications/RAPID/analysis/minimumProjections05.py {}"

rm $PIDFILE
