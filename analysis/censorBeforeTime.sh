#!/bin/bash

BADTIME=$(date --date="2015-12-06 17:30:00" +%s)

censor_bad_time(){
    time=$(head -n1 $1)
    if [ $time -lt $BADTIME ];
    then
        filepath="${1%.*}"
        echo "censored" > $filepath"/censored.txt"
        echo "true"
    else 
        echo "false"
    fi
}
export -f censor_bad_time
export BADTIME

#find $1 -name "timestamp.txt" | parallel "if [ $(head -n1 {}) < $BADTIME ]; then echo true; fi" 
find $1 -name "timestamp.txt" | parallel censor_bad_time {}

