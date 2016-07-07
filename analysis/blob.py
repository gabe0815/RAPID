#!/usr/bin/python

# Standard imports
import cv2
import numpy as np;

# Read image
im = cv2.imread("/home/user/thresholding/imgseries_h264.AVI_2fps.AVI_27_55_after.jpg", cv2.IMREAD_GRAYSCALE)
height, width = im.shape
# Setup SimpleBlobDetector parameters.
params = cv2.SimpleBlobDetector_Params()

# change distance between blobs
params.minDistBetweenBlobs = 20

# Change thresholds
params.minThreshold = 10
params.maxThreshold = 200


# Filter by Area.
params.filterByArea = True
params.minArea = 50

# Filter by Circularity
params.filterByCircularity = False
params.minCircularity = 0.1

# Filter by Convexity
params.filterByConvexity = False
params.minConvexity = 0.87
    
# Filter by Inertia
params.filterByInertia = True
params.minInertiaRatio = 0.01

# Create a detector with the parameters
ver = (cv2.__version__).split('.')
if int(ver[0]) < 3 :
	detector = cv2.SimpleBlobDetector(params)
else : 
	detector = cv2.SimpleBlobDetector_create(params)


# Detect blobs.
keypoints = detector.detect(im)

if len(keypoints) == 0:
    "print no blobs detected"

for blob in keypoints:
    print "size: %f, x: %f, y: %f" % (blob.size, blob.pt[0], blob.pt[1])
    
mask = np.zeros((height, width, 1), np.uint8)
cv2.circle(mask, (int(keypoints[0].pt[0]), int(keypoints[0].pt[1])), int(keypoints[0].size*15), (255,255,255), -1)
mask = cv2.bitwise_not(mask, mask)

# Draw detected blobs as red circles.
# cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS ensures
# the size of the circle corresponds to the size of blob

#im_with_keypoints = cv2.drawKeypoints(im, keypoints, np.array([]), (0,0,255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

# Show blobs

#bitwise or with im
im_blur = cv2.medianBlur(im,21)
masked_data = cv2.add(im_blur, mask)
th1 = cv2.adaptiveThreshold(masked_data,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
            cv2.THRESH_BINARY,15,2)

cv2.namedWindow('Keypoints', cv2.WINDOW_NORMAL)
cv2.imshow("Keypoints", th1)
cv2.waitKey(0)


