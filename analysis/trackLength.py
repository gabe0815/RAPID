import cv2
import numpy as np
from matplotlib import pyplot as plt
import sys
import os

def threshold(parentDir, trackFile, description):
    
    for f in os.listdir(parentDir):
        if '_'+description+'.jpg' in f:
            print f
            thisImage = parentDir + f
   
    #print thisImage
    img = cv2.imread(thisImage,0)
    img = cv2.medianBlur(img,15)    
    height, width = img.shape[:2]


    #thresholding
    th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2) 
    contours, hierarchy = cv2.findContours(th,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
    area = (height*width) - cv2.countNonZero(th)    
    trackFile.write('\n'+description+'\t'+str(0)+'\t'+str(area))
    

    if description == "after":
        for f in os.listdir(parentDir):
            if '_overlay.jpg' in f:
                print f
                thisImage = parentDir + f
                #overlay countour and area
                img = cv2.imread(thisImage,0)            
                overlay = cv2.cvtColor(img,cv2.COLOR_GRAY2BGR)
                cv2.drawContours(overlay, contours, -1, (0,0,255), 1)
                cv2.putText(overlay, str(area), (100,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)  
                cv2.imwrite(thisImage+"_tracklength.jpg", overlay)
   

            
#src = sys.argv[1]
src = '/media/imagesets04/20160321_FIJI_analysis_testing/dl1455724911_2_1_1/'

try:
    os.remove(src + "trackLength.tsv")
except OSError:
    pass

trackLength = open(src + "trackLength.tsv", 'w')
trackLength.write("trackVersion v1\tlength\tarea")

threshold(src, trackLength, "before")
threshold(src, trackLength, "after")

trackLength.close()
