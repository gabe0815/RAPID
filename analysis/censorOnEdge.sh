#!/bin/bash

censor_onEdge(){
    
    if [ $(grep "after" $1 | cut -f4) -eq 1 ];
    then 
        filepath=$(echo $1 | cut -d "/" -f1-5)
        echo "censored" > $filepath"/censored.txt"
    fi
}

export -f censor_onEdge

find $1 -name "trackLength.tsv" | parallel censor_onEdge {}

