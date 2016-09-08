#!/bin/bash

parallel -a /mnt/4TBraid04/imagesets04/20160810_vibassay_set10/sample_N2.FUdR."$1"_sorted_montage_tracklength.jpg_wrongID.txt  "sed -i s/N2\.FUdR\.$1/N2\.FUdR\.$2/g {}/sampleID.txt"

parallel -a /mnt/4TBraid04/imagesets04/20160810_vibassay_set10/sample_N2.FUdR."$2"_sorted_montage_tracklength.jpg_wrongID.txt  "sed -i s/N2\.FUdR\.$2/N2\.FUdR\.$1/g {}/sampleID.txt"
