#!/usr/bin/env python

import numpy as np
import cv2
import cv2.cv as cv
import time
import sys
import os, os.path
from scipy.spatial import distance as dist

def getCenter(cont):
    M = cv2.moments(cont)
    cX = int(M["m10"] / M["m00"])
    cY = int(M["m01"] / M["m00"])
    return (cX, cY)


def measureArea(origImg, threshImg, minArea, minDistance):
    kernel = np.ones((5,5),np.uint8)
  
    nonZeroPixels = cv2.countNonZero(threshImg)
    #reject noisy images and try to improve medium noisy images. 
    if nonZeroPixels > 500000:
        return (-1, np.zeros(threshImg.shape,np.uint8), 0, 0)                    
    elif nonZeroPixels > 50000:
        threshImgEroded = cv2.erode(threshImg, kernel, iterations=2)
        contours, hierarchy = cv2.findContours(threshImgEroded,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)
    else: 
        contours, hierarchy = cv2.findContours(threshImg.copy(),cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)        
        
      
    numberOfContours = len(contours)
    #print numberOfContours
    if numberOfContours == 0:
        return (0, np.zeros(threshImg.shape,np.uint8), 0, numberOfContours)            

    # Find the index of the largest contour
    areas = [cv2.contourArea(cnt) for cnt in contours]
    maxArea = np.amax(areas)
    maxAreaCenter = getCenter(contours[np.argmax(areas)]) 
    
    #find radius of enclosing circle
    (x,y),radius = cv2.minEnclosingCircle(contours[np.argmax(areas)])
    radius = int(radius)
    
    if nonZeroPixels > 50000 and np.std(areas) < 100:
        return (0, np.zeros(threshImg.shape,np.uint8), 0, 0) 

    if maxArea < 4*minArea:
        return (0, np.zeros(threshImg.shape,np.uint8), 0, 0) 

    
   

    mask = np.zeros(threshImg.shape,np.uint8) #for counting contour area
    contourCounter = 0 #tracks number of contours as a measure for noisy tracks
    onEdge = 0
    for cnt in contours:
        if cv2.contourArea(cnt) > minArea:
            D = dist.euclidean(maxAreaCenter, getCenter(cnt))
            if D < 2*radius:  
                cv2.drawContours(mask,[cnt],0,255,-1)
                contourCounter += 1
                #check distance to edges                    
                if np.amin(cnt[:,:,0]) <= 5  or np.amax(cnt[:,:,0]) >= (origImg.shape[1] - 5) or np.amin(cnt[:,:,1]) <= 5 or np.amax(cnt[:,:,1]) >= (origImg.shape[0] - 5):
                    onEdge = 1
                
    if nonZeroPixels > 50000:
        mask = cv2.dilate(mask, kernel, iterations=4) #reverse the erosion from earlier
   
 
    maskedImg = cv2.bitwise_and(threshImg,threshImg,mask=mask)
    #cv2.namedWindow("Image", cv2.WINDOW_NORMAL)
    #cv2.imshow("Image", maskedImg)
    #cv2.waitKey(0)     

    return (cv2.countNonZero(maskedImg), maskedImg, onEdge, contourCounter)


def twoImages(firstImgPath, imgPath1,imgPath2):
    firstImg = cv2.imread(firstImgPath)    
    img1 = cv2.imread(imgPath1)
    img2 = cv2.imread(imgPath2)

    trackImg = cv2.absdiff(firstImg, np.minimum(img1, img2))
    trackGrey = cv2.cvtColor(trackImg, cv2.COLOR_BGR2GRAY)
    return trackGrey
#    trackGreyInverted = cv2.bitwise_not(trackGrey)


#    height, width = trackImg.shape[:2]
#    trackColor = np.zeros((height,width,3), np.uint8)
#    trackColor.fill(255)

#    firstImgGrey = cv2.cvtColor(firstImg, cv2.COLOR_BGR2GRAY)
#    trackColor[:,:,1] = trackGreyInverted[:]

#    weight = 0.5
#    combinedImg = cv2.addWeighted( trackColor, weight, cv2.cvtColor(firstImgGrey, cv2.COLOR_GRAY2BGR,), 1-weight, 0 )
#    cv2.imwrite(sys.argv[3] + "_track.jpg", combinedImg)

path = os.path.dirname(sys.argv[1])

#for i in range(int(sys.argv[2]), int(sys.argv[3])):
#    print "processing %d and %d" % (i,i+1)           
#    #track = twoImages(path +  "/frame" + str(i-1).zfill(4) + ".jpg", path +  "/frame" + str(i).zfill(4) + ".jpg",path +  "/frame" + str(i+1).zfill(4) + ".jpg")
#    track = twoImages(sys.argv[1], path +  "/frame" + str(i).zfill(4) + ".jpg",path +  "/frame" + str(i+1).zfill(4) + ".jpg")
#    cv2.imwrite(path + "/diff" + str(i) + ".jpg", track) 


firstImg = cv2.imread(path + "/diff" + sys.argv[2] + ".jpg")

for i in range(int(sys.argv[2]), int(sys.argv[3])-1):
    print "processing %d and %d" % (i,i+1)
    secondImg = cv2.imread(path + "/diff" + str(i + 1) + ".jpg")
    firstImg = np.maximum(firstImg, secondImg)
    saveImg = firstImg.copy() 
    cv2.putText(saveImg, str(i), (80,850), cv2.FONT_HERSHEY_SCRIPT_SIMPLEX, 5, (255,255,255), 10)
    cv2.imwrite(path + "/projection" + str(i).zfill(4) + ".jpg", saveImg)

kernel = np.ones((5,5),np.uint8)

firstImg = cv2.bitwise_not(firstImg)
img = cv2.medianBlur(cv2.cvtColor(firstImg, cv2.COLOR_BGR2GRAY),17)
   
th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations = 2)
th = cv2.bitwise_not(th)
area, mask, onEdge, contourCounter = measureArea(img, th, 400, 20)
#cv2.namedWindow("Image", cv2.WINDOW_NORMAL)
#cv2.imshow("Image", th)
#cv2.waitKey(0)  
#drawContour on overlay:

ret, dst = cv2.threshold(mask, 127, 255, cv2.THRESH_BINARY)
contours, hierarchy = cv2.findContours(dst,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)

height, width = firstImg.shape[:2]
trackColor = np.zeros((height,width,3), np.uint8)
trackColor.fill(255)

firstImgGrey = cv2.cvtColor(cv2.imread(sys.argv[1]), cv2.COLOR_BGR2GRAY)
firstImg = cv2.cvtColor(firstImg, cv2.COLOR_BGR2GRAY)
trackColor[:,:,1] = firstImg[:]

weight = 0.5
combinedImg = cv2.addWeighted( trackColor, weight, cv2.cvtColor(firstImgGrey, cv2.COLOR_GRAY2BGR,), 1-weight, 0 )


cv2.drawContours(combinedImg, contours, -1, (0,0,255), 1)
cv2.putText(combinedImg, str(area), (30,900), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)
#cv2.putText(combinedImg, str(onEdge), (640,900), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)
cv2.putText(combinedImg, "v11", (950,900) , cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)

cv2.imwrite(sys.argv[1]+"_tracklength.jpg", combinedImg)             

