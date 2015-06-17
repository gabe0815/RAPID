#!/bin/bash

wget -q "http://192.168.1.50/karel/ComGet?sFc=28" -O registers.txt
found=`grep -no  Val1\" registers.txt |cut -f1 -d:`
target=$(($found + 1))
head -n $target registers.txt | tail -1 | cut -f2 -d \"

