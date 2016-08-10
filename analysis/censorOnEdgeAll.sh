#!/bin/bash
while read i; 
do  
     echo "censor on edge in $i";
     /mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/censorOnEdge.sh $i;

done < $1

