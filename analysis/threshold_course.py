#!/usr/bin/env python

import cv2
import numpy as np
from matplotlib import pyplot as plt

origImg = cv2.imread('/home/jhench/mac/Documents/sync/lab_journal/2016/data201607/trackthresholding/noise.jpg',0)

kernel = np.ones((5,5),np.uint8)
titles = ['median blur 15', 'median blur 21', 'median blur 27', 'median blur 31']
sizes = [15, 21, 27, 31]
for i in range(4):
    img = cv2.medianBlur(origImg,sizes[i])
    img = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
    img = cv2.morphologyEx(img, cv2.MORPH_OPEN, kernel, iterations = 2)
    plt.subplot(2,2,i+1),plt.imshow(img,'gray')
    plt.title(titles[i])
    plt.xticks([]),plt.yticks([])
plt.savefig("/mnt/1TBraid01/homefolders/gschweighauser/median_blur_opening_2_noise.png", bbox_inches='tight', format='png', dpi=300)
#plt.show()


