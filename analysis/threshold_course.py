#!/usr/bin/env python

import cv2
import numpy as np
from matplotlib import pyplot as plt

origImg = cv2.imread('/home/user/thresholding/imgseries_h264.AVI_2fps.AVI_27_55_after.jpg',0)

img = cv2.medianBlur(origImg,15)
th1 = cv2.medianBlur(origImg,27)
th2 = cv2.medianBlur(origImg,31)
th3 = cv2.medianBlur(origImg,35)


img = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
            cv2.THRESH_BINARY,15,2)
th1 = cv2.adaptiveThreshold(th1,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
            cv2.THRESH_BINARY,15,2)
th2 = cv2.adaptiveThreshold(th2,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
            cv2.THRESH_BINARY,15,2)
th3 = cv2.adaptiveThreshold(th3,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
            cv2.THRESH_BINARY,15,2)

titles = ['median blur 15', 'median blur 27', 'median blur 31', 'median blur 35']
images = [img, th1, th2, th3]

for i in xrange(4):
    plt.subplot(2,2,i+1),plt.imshow(images[i],'gray')
    plt.title(titles[i])
    plt.xticks([]),plt.yticks([])
plt.show()
