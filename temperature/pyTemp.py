#!/usr/bin/env python

import serial
from time import sleep

ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=5)

ser.write("\x00")
sleep(1);

print "first sensor: %s" % ser.read(5)
print "second sensor: %s" % ser.read(5)	
ser.close()
