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

colorAfterTrackImg = np.zeros((height,width,3), np.uint8)
colorAfterTrackImg.fill(255)

colorAfterTrackImg[:,:,1] = afterTrackImg
weight=0.5
combinedImg = cv2.addWeighted( colorAfterTrackImg, weight, afterPhotoImg, 1-weight, 0 )
cv2.imwrite( sys.argv[1]+"_overlay.jpg", combinedImg)

#cv2.namedWindow('color', cv.CV_WINDOW_NORMAL)
#cv2.imshow('color', combinedImg)
#k = cv2.waitKey(0) & 0xFF
