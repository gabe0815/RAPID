#!/usr/bin/env python
#run this script like this: 
#ls -d /media/imagesets04/20160311_vibassay_set5/*/ |  parallel --eta -j16 "/mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/trackLength.py {}"
from scipy.spatial import distance as dist
import cv2
import numpy as np
import sys
import os


version = "v4"

def threshold(imgPath):
    kernel = np.ones((5,5),np.uint8)
  
    img = cv2.imread(imgPath,0)
    img = cv2.medianBlur(img,17)
    #adaptive threshold goes crazy if there is just noise, so we filter out images with no tracks and return an empty image
    minVal, maxVal, minLoc, maxLoc = cv2.minMaxLoc(img)
    if minVal > 200:
        return cv2.bitwise_not(np.zeros(img.shape,np.uint8))
    
    else:
        #thresholding
        th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
        th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations = 2)
        th = cv2.bitwise_not(th)
        return th        


def findImage(parentDir, description):
    for f in os.listdir(parentDir):
        if f.endswith('_'+description+'.jpg'):
            #print f
            return parentDir + f

    return -1

def getCenter(cont):
    M = cv2.moments(cont)
    cX = int(M["m10"] / M["m00"])
    cY = int(M["m01"] / M["m00"])
    return (cX, cY)


def contourDistance(cont1, cont2, minDist):
    cont1 = np.squeeze(cont1)
    cont2 = np.squeeze(cont2)
    D = dist.cdist(cont1, cont2)
    return np.amin(D)


def measureArea(threshImg, minArea, minDistanceToCenter, minDistance):
    contours, hierarchy = cv2.findContours(threshImg,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE) 
    #find biggest contour        
    maxArea = 0        
    maxCnt = -1
    for cnt in contours:
        if cv2.contourArea(cnt) > maxArea:
            maxArea = cv2.contourArea(cnt)   
            maxCnt = cnt

    mainTrack = getCenter(maxCnt)    

    mask = np.zeros(threshImg.shape,np.uint8) #for counting contour area
    for cnt in contours:
        if cv2.contourArea(cnt) > minArea:
            D = dist.euclidean(mainTrack, getCenter(cnt))
            if D < minDistanceToCenter:
                if D == 0:
                    cv2.drawContours(mask,[cnt],0,255,-1)
                elif contourDistance(maxCnt, cnt, minDistance):
                    #cv2.drawContours(img, cnt, -1, (0,0,255), 1)
                    #drawContours with option -1 draws the interiors without the outline itself
                    cv2.drawContours(mask,[cnt],0,255,-1)
    return (cv2.countNonZero(mask), mask)


def analyseTrack(parentDir, description):
    imgPath = findImage(parentDir, description)
    if imgPath == -1:
        return -1
    else:
        threshImg = threshold(imgPath)
        area, mask = measureArea(threshImg, 50, 500, 20)
        
        #exclude areas which are too big
        if area >= (mask.shape[0] * mask.shape[1] / 6):
            return -1

        #drawContour on overlay:
        if description == "after":
            imgPath = findImage(parentDir, "overlay")
            if imgPath != -1:
                ret, dst = cv2.threshold(mask, 127, 255, cv2.THRESH_BINARY)
                contours, hierarchy = cv2.findContours(dst,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)
                img = cv2.imread(imgPath)
                cv2.drawContours(img, contours, -1, (0,0,255), 1)
                cv2.putText(img, str(area), (100,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)
                cv2.imwrite(imgPath+"_tracklength.jpg", img)            
        return area     
    
################# main program starts here #################

src = sys.argv[1]

descriptions = ("before", "after")

try:
    os.remove(src + "trackLength.tsv")
except OSError:
    pass

trackFile = open(src + "trackLength.tsv", "w")
trackFile.write("trackVersion." + str(version) + "\tlength\tarea")

for descr in descriptions:
    area = analyseTrack(src, descr)
    trackFile.write("\n"+descr+"\t"+str(0)+"\t"+str(area))

trackFile.close()
