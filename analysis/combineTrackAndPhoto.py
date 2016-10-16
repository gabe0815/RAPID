#!/usr/bin/env python


import numpy as np
import cv2
import sys

afterTrackImg = cv2.imread(sys.argv[1],0)
afterPhotoImg = cv2.imread(sys.argv[2])

afterFile = sys.argv[1]

height, width = afterTrackImg.shape


colorAfterTrackImg = np.zeros((height,width,3), np.uint8)
colorAfterTrackImg.fill(255)

colorAfterTrackImg[:,:,1] = afterTrackImg
weight=0.5
combinedImg = cv2.addWeighted( colorAfterTrackImg, weight, afterPhotoImg, 1-weight, 0 )
cv2.imwrite( afterFile[0:afterFile.index("2fps.AVI")+8] +"_before_overlay.jpg", combinedImg)

#cv2.namedWindow('color', cv.CV_WINDOW_NORMAL)
#cv2.imshow('color', combinedImg)
#k = cv2.waitKey(0) & 0xFF
