#!/usr/bin/env python
#run this script like this: 
#ls -d /media/imagesets04/20160311_vibassay_set5/*/ |  parallel --eta -j16 "/home/user/RAPID/analysis/trackLength.py {}"
import cv2
import numpy as np
from matplotlib import pyplot as plt
import sys
import os


version = "v2"

def threshold(parentDir, trackFile, description):
    kernel = np.ones((5,5),np.uint8)

    for f in os.listdir(parentDir):
        if f.endswith('_'+description+'.jpg'):
            #print f
            thisImage = parentDir + f
   
    img = cv2.imread(thisImage,0)
    img = cv2.medianBlur(img,17)
    #get minimum
    minVal, maxVal, minLoc, maxLoc = cv2.minMaxLoc(img)
    if minVal > 200:
        trackFile.write("\n"+description+"\t"+str(0)+"\t"+str(0))
    
    else:
        #thresholding
        th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
        th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations = 2)
        th = cv2.bitwise_not(th)
        contours, hierarchy = cv2.findContours(th,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE) 
        #find biggest contour        
        maxArea = 0        
        maxCnt = -1
        for cnt in contours:
            if cv2.contourArea(cnt) > maxArea:
                maxArea = cv2.contourArea(cnt)   
                maxCnt = cnt

        trackFile.write("\n"+description+"\t"+str(0)+"\t"+str(maxArea))
        

    if description == "after":
        for f in os.listdir(parentDir):
            if f.endswith("_overlay.jpg"):
                thisImage = parentDir + f
                #overlay countour and area
                img = cv2.imread(thisImage)            

                if minVal > 200:
                    cv2.putText(img, str(0), (100,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)  
                else:
                    cv2.drawContours(img, maxCnt, -1, (0,0,255), 1)
                    cv2.putText(img, str(maxArea), (100,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)                      

        cv2.imwrite(thisImage+"_tracklength.jpg", img)
   
src = sys.argv[1]
#src = "/media/imagesets04/20160311_vibassay_set5/dl1457709627_6_1_2/"
try:
    os.remove(src + "trackLength.tsv")
except OSError:
    pass

trackLength = open(src + "trackLength.tsv", "w")
trackLength.write("trackVersion" + str(version) + "\tlength\tarea")

threshold(src, trackLength, "before")
threshold(src, trackLength, "after")

trackLength.close()
