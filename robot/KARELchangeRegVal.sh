#!/bin/bash

#usage $1=INDEX, $2=VALUE
#realflag 1: decimal point, -1: no decimals
urlstring="http://192.168.1.50/karel/ComSet?sValue=$2&sIndx=$1&sRealFlag=-1&sFc=2"
wget -q -O reply.htm $urlstring
