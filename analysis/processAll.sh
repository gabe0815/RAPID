#!/bin/bash
while read i; 
do  
    echo "processing $i";
    ls -d "$i"/*/ |  parallel --eta -j16 "/mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/trackLength.py {}"; 
    echo "assembly of $i";
    /mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/assembleTracklength.sh $i;

done < $1




