#measure distance
#find largest contour
#find center of all contours
#check distance between point of contours which centers are closests and merge the contour


img = cv2.imread(thisImage,0)
img = cv2.medianBlur(img,17)

#thresholding
th = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY,15,2)
th = cv2.morphologyEx(th, cv2.MORPH_OPEN, kernel, iterations = 2)
th = cv2.bitwise_not(th)
contours, hierarchy = cv2.findContours(th,cv2.RETR_LIST,cv2.CHAIN_APPROX_NONE) 

#find biggest contour         

minArea = 50
maxArea = 0        
maxCnt = -1

for cnt in contours:
    if cv2.contourArea(cnt) > maxArea:
        maxArea = cv2.contourArea(cnt)   
        maxCnt = cnt

center = 
for cnt in contours:
    
        
