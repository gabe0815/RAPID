#measure distance
#find largest contour
#find center of all contours
#check distance between point of contours which centers are closests and merge the contour
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



thisImage = "/home/user/mac/Documents/sync/lab_journal/2016/data201607/trackthresholding/noise.jpg"

kernel = np.ones((5,5),np.uint8)



img = cv2.imread(thisImage,0)
img = cv2.medianBlur(img,17)

#thresholding
th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations = 2)
th = cv2.bitwise_not(th)
contours, hierarchy = cv2.findContours(th,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE) 

#find biggest contour         

minArea = 50
maxArea = 0        
maxCnt = -1
totalArea = 0
minDistanceToCenter = 500
minDistance = 50

for cnt in contours:
    if cv2.contourArea(cnt) > maxArea:
        maxArea = cv2.contourArea(cnt)   
        maxCnt = cnt

mainTrack = getCenter(maxCnt)

for cnt in contours:
    if cv2.contourArea(cnt) > minArea:
        D = dist.euclidean(mainTrack, getCenter(cnt))
        if D < minDistanceToCenter:
            cv2.drawContours(img, cnt, -1, (0,0,255), 1)
            print "distance: %d area: %d" % (D, cv2.contourArea(cnt))

cv2.namedWindow("Image", cv2.WINDOW_NORMAL)
cv2.imshow("Image", img)
cv2.waitKey(0)   


    
        

