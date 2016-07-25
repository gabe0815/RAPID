#!/bin/bash
while read i; 
do  
    ls -d "$i"/*/ |  parallel --eta -j16 "/mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/trackLength.py {}"; 
    /mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/assembleTracklength.sh $i;

done < $1




