import cv2
import numpy as np
from matplotlib import pyplot as plt
import sys

#srcPath = sys.argv[1]

src = '/media/imagesets04/20160217_vibassay_set4/dl1455724911_2_1_1/imgseries_h264.AVI_2fps.AVI_27_54_after.jpg'

img = cv2.imread(src,0)
img = cv2.medianBlur(img,15)

ret,th1 = cv2.threshold(img,250,255,cv2.THRESH_BINARY)
th2 = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2) # performs similar to imagej
th2_copy = th2.copy()
contours, hierarchy = cv2.findContours(th2_copy,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
#th3 = img.copy()
th3 = cv2.cvtColor(img,cv2.COLOR_GRAY2BGR)
cv2.drawContours(th3, contours, -1, (0,0,255), 1)

height, width = img.shape[:2]
area = (height*width) - cv2.countNonZero(th2)

cv2.putText(th3, str(area), (100,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)

#th3 = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,cv2.THRESH_BINARY,15,2)

titles = ['Original Image', 'Global Thresholding (v = 127)','Adaptive Mean Thresholding', 'Adaptive Gaussian Thresholding']
images = [img, th1, th2, th3]

cv2.imwrite(src+"_tracklength.jpg", th3)



for i in xrange(4):
    plt.subplot(2,2,i+1),plt.imshow(images[i],'gray')
    plt.title(titles[i])
    plt.xticks([]),plt.yticks([])
    
plt.show()
