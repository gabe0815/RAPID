#!/usr/bin/env python

import cv2
import numpy as np
from matplotlib import pyplot as plt

#origImg = cv2.imread('/home/jhench/mac/Documents/sync/lab_journal/2016/data201607/trackthresholding/noise.jpg',0)

kernel = np.ones((5,5),np.uint8)
titles = ['median blur 15', 'median blur 21', 'median blur 27', 'median blur 31']
sizes = [15, 21, 27, 31]
for i in range(4):
    origImg = cv2.imread('/home/jhench/mac/Documents/sync/lab_journal/2016/data201607/trackthresholding/clean.jpg',0)
    img = cv2.medianBlur(origImg,sizes[i])
    #if binarization is inverted, we have to close the binary instead of open    
    img = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
    img = cv2.morphologyEx(img, cv2.MORPH_OPEN, kernel, iterations = 2)
    #find biggest contour
    img = cv2.bitwise_not(img)
    contours, hierarchy = cv2.findContours(img,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)
    maxArea = 0    
    maxCnt = -1    
    for cnt in contours:
        if cv2.contourArea(cnt) > maxArea:
            maxArea = cv2.contourArea(cnt)
            maxCnt = cnt
    print maxArea
    origImg = cv2.imread('/home/jhench/mac/Documents/sync/lab_journal/2016/data201607/trackthresholding/clean.jpg')
    cv2.drawContours(origImg, maxCnt, -1, (0,0,255), 3)
    #(x,y),radius = cv2.minEnclosingCircle(maxCnt)
    #center = (int(x),int(y))
    #radius = int(radius)
    #cv2.circle(img,center,radius,(0,255,0),2)    
    plt.subplot(2,2,i+1),plt.imshow(origImg,'gray')
    plt.title(titles[i])
    plt.xticks([]),plt.yticks([])
plt.savefig("/mnt/1TBraid01/homefolders/gschweighauser/median_blur_opening_2.png", bbox_inches='tight', format='png', dpi=300)
#plt.show()


