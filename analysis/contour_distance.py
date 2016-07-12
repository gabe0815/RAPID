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

#print maxCnt[1][0][0]

for x in maxCnt[:]:
    print "x: %d y: %d" % (x[0][0], x[0][1])

#for cnt in contours:
#    if cv2.contourArea(cnt) > minArea:
#        D = dist.euclidean(mainTrack, getCenter(cnt))
#        if D < minDistanceToCenter:
#           for p1 in maxCnt:
#                thisPoint = (maxCnt[p1][0][0], maxCnt[p1][0][1]) 
#                for p2 in cnt:
#                    distance = dist.euclidean(thisPoint, (cnt[p2][0][0], cnt[p2][0][1]))
#                    if distance < minDistance:
#                        print "Distance: %d" % distance
#                        break

cv2.namedWindow("Image", cv2.WINDOW_NORMAL)
cv2.imshow("Image", img)
cv2.waitKey(0)   


    
        

