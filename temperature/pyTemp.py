#!/usr/bin/env python

import serial
from time import sleep
import os 
#remove old log file
try:
    os.remove("/tmp/temperature.log")
except OSError:
    pass

ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=5)

ser.write("\x00")
sleep(1);

with open("/tmp/temperature.log", "a") as myfile:
	myfile.write(ser.read(5))
	myfile.write(",")
	myfile.write(ser.read(5))

ser.close()
