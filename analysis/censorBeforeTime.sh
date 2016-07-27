#!/bin/bash

BADTIME=$(date --date="2015-12-06 17:30:00" +%s)

for i in $(find $1 -name "timestamp.txt"); 
do 
    echo $i
done
