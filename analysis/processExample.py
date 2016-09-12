#!/usr/bin/env python

import numpy as np
import cv2
import cv2.cv as cv
import time
import sys
import os, os.path

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

for i in range(int(sys.argv[2]), int(sys.argv[3])):
    print "processing %d and %d" % (i,i+1)           
    #track = twoImages(path +  "/frame" + str(i-1).zfill(4) + ".jpg", path +  "/frame" + str(i).zfill(4) + ".jpg",path +  "/frame" + str(i+1).zfill(4) + ".jpg")
    track = twoImages(sys.argv[1], path +  "/frame" + str(i).zfill(4) + ".jpg",path +  "/frame" + str(i+1).zfill(4) + ".jpg")
    cv2.imwrite(path + "/diff" + str(i) + ".jpg", track) 


firstImg = cv2.imread(path + "/diff" + sys.argv[2] + ".jpg")

for i in range(int(sys.argv[2]), int(sys.argv[3])):
    print "processing %d and %d" % (i,i+1)
    secondImg = cv2.imread(path + "/diff" + str(i + 1) + ".jpg")
    firstImg = np.maximum(firstImg, secondImg)
    cv2.imwrite(path + "/projection" + str(i).zfill(4) + ".jpg", firstImg)
