#!/usr/bin/env python

# usage:
# find `pwd` -name "imgseries_h264.AVI" | parallel ~/applicatins/RAPID/analysis/minimumProjections05.py {} 

import numpy as np
import cv2
import cv2.cv as cv
import time
import sys
import os, os.path


startTime = time.time()

vidPath = sys.argv[1]
vidFile = cv2.VideoCapture ( vidPath )

nFrames = int( vidFile.get( cv.CV_CAP_PROP_FRAME_COUNT ) )

timestamps = vidPath + "_metadata.txt_extract.txt"
with open(timestamps) as f:
    seconds = f.readlines()

for i in xrange(len( seconds )):
    if (abs(int(seconds[i+1]) - int(seconds[i])) >= 4):
	#skip the frame at which the vibration started, use the one before that
        before_end = i-1
        break


before_start = 0
#as we use a frame before the vibration started, we have to increase by 2 to take the one after the vibration started
after_start = before_end + 2
after_end = nFrames


print("File: %s, Number of Frames: %d, before start: %d, before_end %d, after start: %d, after end %d") % (vidPath, nFrames, before_start, before_end, after_start, after_end)



#write parameters to text file
paramPath = vidPath + "_parameters.txt"
with open(paramPath, 'w') as parameters:
    parameters.write(str(before_start) + '\n')
    parameters.write(str(before_end) + '\n')
    parameters.write(str(after_start) + '\n')
    parameters.write(str(after_end) + '\n')


#create paths for saving jpegs
imgBefore = vidPath + "_2fps.AVI_"+str(before_start)+"_"+str(before_end) + "_before.jpg"
imgAfter = vidPath + "_2fps.AVI_"+str(after_start)+"_"+str(after_end) + "_after.jpg"


#print ("before_start %d, before_end %d, after_start %d, after_end %d") % (before_start, before_end, after_start, after_end)




for f in xrange( nFrames ):
    ret, frame = vidFile.read()
    #if f == 0:
        #cv2.imwrite(firstFrame, cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY))
        

    if f >= before_start and f <= before_end:
        if f == before_start:
#            last_image = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            beforePath = vidPath + "_2fps.AVI_"+str(before_start)+".jpg"            
            cv2.imwrite(beforePath, cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY))
            last_image = frame
            first_before = last_image
	
        else:
#	    current_image = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            current_image = frame			
            before_projection = np.minimum(last_image, current_image)
            last_image = before_projection
   
    elif f >= after_start and f <= after_end:
        if f == after_start:
#            last_image = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            afterPath = vidPath + "_2fps.AVI_"+str(after_start)+".jpg"            
            cv2.imwrite(afterPath, cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY))
            last_image = frame
            first_after = last_image
        else:
#	     current_image = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            current_image = frame		
            after_projection = np.minimum(last_image, current_image)
            last_image = after_projection




#subtract first image, invert and convert to gray
before_projection= cv2.absdiff(before_projection, first_before)
after_projection = cv2.absdiff(after_projection, first_after)


before_projection = cv2.cvtColor(before_projection, cv2.COLOR_BGR2GRAY)
after_projection = cv2.cvtColor(after_projection, cv2.COLOR_BGR2GRAY)

#create colored tracks from before and after and combine to one image
height, width = before_projection.shape[:2]

colorBefore = np.zeros((height,width,3), np.uint8)
colorAfter = np.zeros((height,width,3), np.uint8)

colorBefore[:,:,0] = before_projection[:]
colorAfter[:,:,2] = after_projection[:]

weight=0.5
combinedImg = cv2.addWeighted( colorBefore, weight, colorAfter, 1-weight, 0 )

before_projection = cv2.bitwise_not(before_projection)
after_projection = cv2.bitwise_not(after_projection)

#combine colour track with photo
colorAfterTrackImg = np.zeros((height,width,3), np.uint8)
colorAfterTrackImg.fill(255)

weight=0.5

#we have to convert the color to gray and the back again to get a 3 channel gray image to overlay with the track
afterPhotoImg = cv2.cvtColor(first_after, cv2.COLOR_BGR2GRAY)

colorAfterTrackImg[:,:,1] = after_projection[:]
combinedTrackAndPhoto = cv2.addWeighted( colorAfterTrackImg, weight, cv2.cvtColor(afterPhotoImg, cv2.COLOR_GRAY2BGR,), 1-weight, 0 )


cv2.imwrite(imgBefore, before_projection)
cv2.imwrite(imgAfter, after_projection)
cv2.imwrite(vidPath + "_2fps.AVI_combined.jpg", combinedImg)
cv2.imwrite(vidPath + "_2fps.AVI_overlay.jpg", combinedTrackAndPhoto)


vidFile.release()

#print "finished in %d seconds" % (time.time() - startTime)
