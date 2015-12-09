#!/bin/bash
#usage:
# find /mnt/4TBraid02/20151203_vibassay_set2/ -name "temperature.txt" -exec ~/applications/RAPID/analysis/parseTemp.sh {} \;
#note: exec can't handle more than one expression, hence the script. 


TIMEFILE=$(dirname $1)"/timestamp.txt"
TIME=$(cat $TIMEFILE)
DATE=$(date -d @$TIME +'%D %T')

printf %s "$DATE," ; head -n1 $1; echo -e ""
