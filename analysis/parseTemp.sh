#!/bin/bash

#$IMAGEPATH is stored globally for all scripts in config.sh

. ~/applications/RAPID/analysis/config.sh

TEMPFILE=$IMAGEPATH"/temp.log"

function extractTemp (){

	TIMEFILE=$(dirname $1)"/timestamp.txt"
	TIME=$(cat $TIMEFILE)
	DATE=$(date -d @$TIME +'%d/%m/%y %T')

	printf %s "$DATE," ; head -n1 $1; echo -e ""

}
export -f extractTemp

if [ -f $TEMPFILE ] 
then
	rm $TEMPFILE
fi

find $IMAGEPATH -name "temperature.txt" -exec bash -c 'extractTemp {}' >> $IMAGEPATH"/temp.log" \;
