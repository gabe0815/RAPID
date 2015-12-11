#!/bin/bash

#IMAGEPATH is stored in config.sh to make it accessible to all scripts
. config.sh

#get sample list 
if [ -f $IMAGEPATH/sampleIDs.txt ]; then
    rm $IMAGEPATH/sampleIDs.txt 
fi

for i in $(find $IMAGEPATH -name "sampleID.txt"); do echo -en $i'\t'; head -n1 $i; done >> $IMAGEPATH"/sampleIDs.txt"


#get unique sampleID
cut -f2 $IMAGEPATH"/sampleIDs.txt" | sort | uniq >> $IMAGEPATH"/sampleIDs_uniqe.txt"

#compile list for each sampleID
while read j; do grep "\<$j\>" $IMAGEPATH"/sampleIDs.txt" > $IMAGEPATH"/sample_$j.txt"; done < $IMAGEPATH"/sampleIDs_uniqe.txt"

#create a mosaic

