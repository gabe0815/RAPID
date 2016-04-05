import cv2
import numpy as np
from matplotlib import pyplot as plt
import sys

#src = sys.argv[1]

src = '/media/imagesets04/20160217_vibassay_set4/dl1455724911_2_1_1/imgseries_h264.AVI_2fps.AVI_27_54_after.jpg'
img = cv2.imread(src,0)
height, width = img.shape[:2]
img = cv2.medianBlur(img,15)

#thresholding
th2 = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2) 
contours, hierarchy = cv2.findContours(th2,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

#overlay countour and area
overlay = cv2.cvtColor(img,cv2.COLOR_GRAY2BGR)
cv2.drawContours(overlay, contours, -1, (0,0,255), 1)
area = (height*width) - cv2.countNonZero(th2)
cv2.putText(overlay, str(area), (100,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)

#cv2.imwrite(src+"_tracklength.jpg", th3)
#cv2.namedWindow("overlay", cv2.WINDOW_NORMAL)
#cv2.imshow("overlay", overlay)
#cv2.waitKey(-1)

