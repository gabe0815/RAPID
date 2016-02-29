#!/usr/bin/env python

from matplotlib import pyplot as plt
import numpy as np
from matplotlib import dates
from datetime import datetime
import sys

d=[]
t1=[]
t2=[]

with open(sys.argv[1]) as f:
    for line in f:
        sep = line.split(',')
        if len(sep) == 3:
        #print sep
            if ((sep[1] or sep[2]) == "-1"):
                continue
            elif (not sep[1] or not sep[2]):            
                continue            
            else:
                #print sep
                d.append(datetime.fromtimestamp(int(sep[0])))
                t1.append(float(sep[1]))
                t2.append(float(sep[2]))
plt.ylabel('Temperature [C]')
#plt.ylim( 24.5, 29 )
plt.plot(d,t1,'r.', d,t2,'b.')
plt.yticks(np.arange(24.5, 29.5, 0.5))
plt.axhline(y=np.mean(t1), color='r', linestyle='dashed')
plt.axhline(y=np.mean(t2), color='b', linestyle='dashed')
plt.show()
