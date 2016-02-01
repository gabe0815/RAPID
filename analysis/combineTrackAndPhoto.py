#!/usr/bin/env python


import numpy as np
import cv2
import cv2.cv as cv
import time
import sys
import os, os.path

afterTrackImg = cv2.imread(sys.argv[1])
afterPhotoImg = cv2.imread(sys.argv[2])

height, width, channels = afterTrackImg.shape
afterTrackImg = cv2.cvtColor(afterTrackImg,  cv.CV_BGR2GRAY)
#afterTrackImgNorm = cv2.equalizeHist(afterTrackImg)

#try adaptive thresholding
#cv2.adaptiveThreshold(src, maxValue, adaptiveMethod, thresholdType, blockSize, C)
#maybe try otsu next
afterTrackThresh = cv2.adaptiveThreshold(afterTrackImg, 255,  cv.CV_ADAPTIVE_THRESH_GAUSSIAN_C, cv.CV_THRESH_BINARY, 11, 2)

colorAfterTrackImg = np.zeros((height,width,3), np.uint8)
colorAfterTrackImg.fill(255)

colorAfterTrackImg[:,:,1] = afterTrackThresh
weight=0.5
combinedImg = cv2.addWeighted( colorAfterTrackImg, weight, afterPhotoImg, 1-weight, 0 )
cv2.imwrite( sys.argv[1]+"_thresh.jpg", combinedImg)

#cv2.namedWindow('color', cv.CV_WINDOW_NORMAL)
#cv2.imshow('color', combinedImg)
#k = cv2.waitKey(0) & 0xFF
