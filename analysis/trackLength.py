#!/usr/bin/env python
#run this script like this: 
#ls -d /media/imagesets04/20160311_vibassay_set5/*/ |  parallel --eta -j16 "/mnt/1TBraid01/homefolders/gschweighauser/RAPID/analysis/tracklength.py {}"
from scipy.spatial import distance as dist
import cv2
import numpy as np
import sys
import os


version = "v12"

def getCenter(cont):
    M = cv2.moments(cont)
    cX = int(M["m10"] / M["m00"])
    cY = int(M["m01"] / M["m00"])
    return (cX, cY)

def find_if_close(cnt1, cnt2, minDistance):
#http://dsp.stackexchange.com/questions/2564/opencv-c-connect-nearby-contours-based-on-distance-between-them
    D = dist.cdist(np.squeeze(cnt1), np.squeeze(cnt2))
    if np.amin(D) < minDistance:
        return True
    else:
        return False

def createMask(contours, threshImg, minDistance):
    
    mask = np.zeros(threshImg.shape,np.uint8) #for counting contour area

    #find center of biggest contour
    for cnt in contours:
        if cv2.contourArea(cnt) > 100 and cv2.contourArea(cnt) < 10000:
            cv2.drawContours(mask,[cnt],0,255,-1)

    contours,hier = cv2.findContours(mask,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)
    areas = [cv2.contourArea(cnt) for cnt in contours]
    maxArea = np.amax(areas)
    maxAreaCenter = getCenter(contours[np.argmax(areas)]) 

    #combine contours that are closer to minDistance, then select the hull which contains the biggest contour
    length = len(contours)
    if length < 2:
        return (True, np.zeros(threshImg.shape,np.uint8))
    
    status = np.zeros((length,1))
    for i,cnt1 in enumerate(contours):
        x = i
        if i != length-1:
            for j,cnt2 in enumerate(contours[i+1:]):
                x = x+1
                close = find_if_close(cnt1,cnt2,minDistance)
                if close == True:
                    val = min(status[i],status[x])
                    status[x] = status[i] = val
                else:
                    if status[x]==status[i]:
                        status[x] = i+1

    unified = []
    maximum = int(status.max())+1
    for i in xrange(maximum):
        pos = np.where(status==i)[0]
        if pos.size != 0:
            cont = np.vstack(contours[i] for i in pos)
            hull = cv2.convexHull(cont)
            unified.append(hull)


        mask = np.zeros(threshImg.shape,np.uint8)
        cv2.drawContours(mask,unified,-1,255,-1)
        

    maskArea = np.zeros(threshImg.shape,np.uint8)
    contours,hier = cv2.findContours(cv2.bitwise_not(mask.copy()),cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)

    for cnt in contours:
        if cv2.pointPolygonTest(cnt, maxAreaCenter, measureDist=False) == 1:
            cv2.drawContours(maskArea, [cnt], 0, 255,-1)
            break

    return (False, maskArea)

    
def threshold(imgPath):
    kernel = np.ones((5,5),np.uint8)
  
    img = cv2.imread(imgPath,0)
    img = cv2.medianBlur(img,17)

    #adaptive threshold goes crazy if there is just noise, so we filter out images with no tracks and return an empty image
    minVal, maxVal, minLoc, maxLoc = cv2.minMaxLoc(img)
    if minVal > 220:
        return (img, np.zeros(img.shape,np.uint8))
    
    else:
        #thresholding
        th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
        th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations = 2)
        th = cv2.bitwise_not(th)
        return (img, th)        


def findImage(parentDir, description):
    for f in os.listdir(parentDir):
        if f.endswith('_'+description+'.jpg'):
            return parentDir + f

    return -1

def measureArea(origImg, threshImg, minDistance):
    kernel = np.ones((5,5),np.uint8)
  
    nonZeroPixels = cv2.countNonZero(threshImg)
    #reject noisy images and try to improve medium noisy images. 
    if nonZeroPixels > 500000:
        return (-1, np.zeros(threshImg.shape,np.uint8), 0)                    

    else: 
        contours, hierarchy = cv2.findContours(threshImg.copy(),cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)

    #apply mask   
    empty, mask = createMask(contours, threshImg, minDistance)

    if empty:
        return (0, np.zeros(threshImg.shape,np.uint8), 0) 
    
    maskedImg = cv2.bitwise_and(threshImg,threshImg,mask=mask)
    contours, hierarchy = cv2.findContours(maskedImg.copy(),cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)
    #check if on edge
    onEdge = 0
    for cnt in contours:
        #check distance to edges                    
        if np.amin(cnt[:,:,0]) <= 5  or np.amax(cnt[:,:,0]) >= (origImg.shape[1] - 5) or np.amin(cnt[:,:,1]) <= 5 or np.amax(cnt[:,:,1]) >= (origImg.shape[0] - 5):
            onEdge = 1

    #draw contours to measure area
    maskArea = np.zeros(threshImg.shape,np.uint8)
    cv2.drawContours(maskArea,contours,-1,255,-1)
    
    
#    cv2.namedWindow("Image", cv2.WINDOW_NORMAL)
#    cv2.imshow("Image", maskedImg)
#    cv2.waitKey(0)     

    return (cv2.countNonZero(maskArea), maskedImg, onEdge)


def analyseTrack(parentDir, description):
    imgPath = findImage(parentDir, description)
    if imgPath == -1:
        return -1, 0, 0
    else:
        img, th = threshold(imgPath)
        area, mask, onEdge = measureArea(img, th, 50) #chose 50px as max distance

        #drawContour on overlay:
        if description == "after":
            imgPath = findImage(parentDir, "overlay")
            if imgPath != -1:
                ret, dst = cv2.threshold(mask, 127, 255, cv2.THRESH_BINARY)
                contours, hierarchy = cv2.findContours(dst,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE)
                img = cv2.imread(imgPath)
                cv2.drawContours(img, contours, -1, (0,0,255), 1)
                cv2.putText(img, str(area), (100,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)
                cv2.putText(img, str(onEdge), (1500,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)
                cv2.putText(img, str(version), (2700,2200), cv2.FONT_HERSHEY_SIMPLEX, 5, (0,0,255), 10)

                cv2.imwrite(imgPath+"_tracklength.jpg", img)            
        
        return area, onEdge  
    
################# main program starts here #################

src = sys.argv[1]

descriptions = ("before", "after")

try:
    os.remove(src + "tracklength.tsv")
except OSError:
    pass

trackFile = open(src + "tracklength.tsv", "w")
trackFile.write("trackVersion." + str(version) + "\tlength\tarea\tedge")


for descr in descriptions:
    area, onEdge = analyseTrack(src, descr)
    trackFile.write("\n"+descr+"\t"+str(0)+"\t"+str(area)+"\t"+str(onEdge)+"\t") 
    #if descr == "after" and onEdge: #we don't want to censor tracks based on "before" image ...
    #    censorFile = open(src + "censored.txt", "w")
    #    censorFile.write("censored")
    #    censorFile.close()

trackFile.close()

