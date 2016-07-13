#!/usr/bin/env python

#note: contourArea is different from non-zero pixels as it uses another formula:
#http://docs.opencv.org/2.4/modules/imgproc/doc/structural_analysis_and_shape_descriptors.html#cv2.contourArea
#therefore, we'll only use countArea as approximation and use non-zero pixels for final reporting
#scipy: sudo apt-get install libblas-dev liblapack-dev libatlas-base-dev gfortran pip install scipy

from scipy.spatial import distance as dist
import cv2
import numpy as np
import sys
import os

def getCenter(cont):
    M = cv2.moments(cont)
    cX = int(M["m10"] / M["m00"])
    cY = int(M["m01"] / M["m00"])
    return (cX, cY)


def contourDistance(cont1, cont2, minDist):
    #check distance from cont1 to cont2 for all points until minDist is reached.
    for p1 in cont1[:]:
        thisPoint = (p1[0][0], p1[0][1]) 
        for p2 in cont2[:]:
            distance = dist.euclidean(thisPoint, (p2[0][0], p2[0][1]))
            if distance < minDist:
                return 1
    
    return 0               


thisImage = "/home/user/mac/Documents/sync/lab_journal/2016/data201607/trackthresholding/imgseries_h264.AVI_2fps.AVI_27_55_after.jpg"

kernel = np.ones((5,5),np.uint8)

img = cv2.imread(thisImage,0)
img = cv2.medianBlur(img,17)

#thresholding
th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations = 2)
th = cv2.bitwise_not(th)
contours, hierarchy = cv2.findContours(th,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE) 


minArea = 50
maxArea = 0        
maxCnt = -1
minDistanceToCenter = 500
minDistance = 20

#find biggest contour and its center
for cnt in contours:
    if cv2.contourArea(cnt) > maxArea:
        maxArea = cv2.contourArea(cnt)   
        maxCnt = cnt
mainTrack = getCenter(maxCnt)

#loop through all contours, measure center to center distance and closest points
mask = np.zeros(img.shape,np.uint8) #for counting contour area

for cnt in contours:
    if cv2.contourArea(cnt) > minArea:
        D = dist.euclidean(mainTrack, getCenter(cnt))
        if D < minDistanceToCenter:
            if contourDistance(maxCnt, cnt, minDistance):
                cv2.drawContours(img, cnt, -1, (0,0,255), 1)
                #drawContours with option -1 draws the interiors without the outline itself
                cv2.drawContours(mask,[cnt],0,255,-1)
    
print "non overlaping area: %d" % cv2.countNonZero(mask)
#cv2.imwrite("/home/user/track.jpg", mask)
cv2.namedWindow("Image", cv2.WINDOW_NORMAL)
cv2.imshow("Image", mask)
cv2.waitKey(0)   


    
        

