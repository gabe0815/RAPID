var outputSize = 512; //px
//var outputSize = 256; //px
//var overviewSize = 1830; //px
var overviewSize = 2304; //px
var scaling = 0.66; //%
var parentPath="/mnt/1TBraid01/imagesets01/20150508_vibassay_continous"; // no "/" at the end
//var groupIDs=newArray("N2L4","IFP53L4","IFP53rrL4","IFP53ggL4","IFP55L4","IFP55rrL4","IFP55ggL4","IFP43L4m");
//var groupIDs=newArray("IFP53mL4","IFP53rrmL4","IFP53ggmL4","IFP55mL4","IFP55rrmL4","IFP55ggmL4","IFP43mL4","N2L4m20black","N2L4m21hblack","N2L4m22hblack","N2L4m23hblack","N2L4m24hblack","N2L4m25hblack","N2L4m26hblack","IFP53L4m22black","IFP53L4m23black","IFP53L4m24black","IFP53L4m25black","IFP53L4m26black","IFP53L4m27black","IFP53L4m28black","IFP53rrL4m23hblack","IFP53rrL4m24hblack","IFP53rrL4m25hblack","IFP53rrL4m26hblack","IFP53rrL4m27hblack","IFP53rrL4m28hblack","IFP53rrL4m29hblack","IFP53ggL4m18hblack","IFP53ggL4m19hblack","IFP53ggL4m20hblack","IFP53ggL4m21hblack","IFP53ggL4m22hblack","IFP53ggL4m23hblack","IFP53ggL4m24hblack","IFP55L4m30hblack","IFP55L4m31hblack","IFP55L4m32hblack","IFP55L4m33hblack","IFP55L4m34hblack","IFP55L4m35hblack","IFP55L4m36hblack","IFP55rrL4m20hblack","IFP55rrL4m21hblack","IFP55rrL4m22hblack","IFP55rrL4m23hblack","IFP55rrL4m24hblack","IFP55rrL4m25hblack","IFP55rrL4m26hblack","IFP55ggL4m23hblack","IFP55ggL4m24hblack","IFP55ggL4m25hblack","IFP55ggL4m26hblack","IFP55ggL4m27hblack","IFP55ggL4m28hblack","IFP55ggL4m29hblack","IFP43L4m18hblack","IFP43L4m19hblack","IFP43L4m20hblack","IFP43L4m21hblack","IFP43L4m22hblack","IFP43L4m23hblack","CK10L4m01hblack","CK10L4m02hblack","CK10L4m03hblack","CK10L4m04hblack","CK10L4m05hblack","CK10L4m06hblack","CK10L4m07hblack","IFP53_201409","IFP53rr_201409","IFP53gg_201409","IFP55_201409","IFP55rr_201409","IFP55gg_201409","CK10_201410","IFP52_201410","IFP53_201410","IFP53gg_201410","IFP53rr_201410");
//var groupIDs=newArray("CK10_2014","IFP52","IFP53_2014","IFP53gg_2014","IFP53rr_2014","N2_2014","SS104_egglay","SS104_NGM","IFP134_NGM","IFP141_NGM", "IFP142_NGM");
var groupIDs=newArray("IFP151", "IFP157");
//var groupIDs=newArray("CK10_201410");
var timeExclude=newArray(1406674117,1406809914,1408820296, 1408950513);
var gaussSigma=2;
var minPixels=100; //minimum pixels for a real track
var tMax=113; //highest round number
var recalculateAll = false;

var imgSizeX=3072;
var imgSizeY=2304;

var logfilePath=parentPath+"/log.txt";

macro "daemon [d]"{
	//wt=1000*3600*5;
	wt=0;
	print ("waiting "+wt/1000/3600+"h...");
	wait(wt);
	
	while (1==1){
		run("all [a]");
		print("waiting 1 h");
		wait(1000*60*60);
	}
}

macro "all [a]"{
	run("whole [w]");
	run("create matching set lists [l]");
	run("create ID-based mosaic [i]");
	run("make HTML overview [h]");
}

macro "whole [w]"{
	run("ROI Manager...");
	setBatchMode(true);
	analyzeWholeDir(parentPath);
	setBatchMode(false);
}

macro "make HTML overview [h]"{
	makeHTMLoverview();
}

function closeAllImagesForSure(){
	while (nImages > 0){
		selectImage(nImages);
		close();	
	}
}

function analyzeWholeDir(parentDir){
	pathes=split(exec("find",parentDir,"-name","*_combined.jpg"),"\n");
	
	for (i=0;i<lengthOf(pathes);i++){
		imgPath=pathes[i];
		File.append(imgPath, logfilePath);
		colorImageFile=imgPath+"_best_track_colored.jpg";
		if((recalculateAll == false) && (File.exists(colorImageFile)==false)){
			roiPath=""+substring(pathes[i], 0, lengthOf(pathes[i])-4)+"_ROIs.zip";
			outlinePath=getOutlinePath(pathes[i]);
			print(roiPath);
			print(imgPath);
			print(outlinePath);
			if ((File.exists(imgPath)==true) && (File.exists(roiPath)==true)){
				extractPathImage(imgPath,roiPath);
			}
			findSingleTrack(imgPath);
			
			if ((File.exists(colorImageFile)==true)  && (File.exists(outlinePath)==true)){
				extractOverviewImage(colorImageFile,outlinePath);
			}
			else{
				if((File.exists(imgPath)==true) && (File.exists(outlinePath)==true)){
					extractOverviewImage(imgPath,outlinePath);
				}
			}
				
		}else{
				print("already analyzed, skipping");
		}
		closeAllImagesForSure();
		print("---------------");
	}
}

function getOutlinePath(thisPath){
	parentDirRaw=exec("dirname",thisPath);
	parentDirSplit=split(parentDirRaw,"\n");
	parentDir=parentDirSplit[0];
	parentFiles=getFileList(parentDir);
	for (f=0;f<lengthOf(parentFiles);f++){
		if(endsWith(parentFiles[f],"outlineROI.zip")==true){
			outlinePath=parentDir+"/"+parentFiles[f];
		}
	}
	return outlinePath;
}

function extractPathImage(imgPath,roiPath){	
	roiManager("reset");
	open(imgPath);
	origImg=getImageID();
	filePath=getInfo("image.directory");
	roiManager("reset");
	open(roiPath);
	saveImgPath=""+filePath+"/AfterTrack.jpg";
	nRois=roiManager("count");
	maxPixels=0;
	largestRoi=0;
	for (i=0;i<nRois;i++){
		roiManager("Select",i);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		if (nPixels>maxPixels){
			largestRoi=i;
		}
	}
	roiManager("Select",largestRoi);
	getSelectionBounds(x, y, width, height);
	centerX=round(x+width/2);
	centerY=round(y+height/2);
	copyX=round(centerX-outputSize/2);
	copyY=round(centerY-outputSize/2);
	makeRectangle(copyX,copyY,outputSize,outputSize);
	run("Copy");
	newImage("saveImg", "RGB white", outputSize, outputSize, 1);
	saveImg=getImageID();
	run("Select None");
	run("Paste");
	saveAs("jpeg",saveImgPath);
	close();
	selectImage(origImg);
	close();
}

function extractOverviewImage(imgPath,roiPath){	
	roiManager("reset");
	open(imgPath);
	origImg=getImageID();
	filePath=getInfo("image.directory");
	roiManager("reset");
	open(roiPath);
	saveImgPath=""+filePath+"/AfterOverview.jpg";
	nRois=roiManager("count");
	maxPixels=0;
	largestRoi=0;
	for (i=0;i<nRois;i++){
		roiManager("Select",i);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		if (nPixels>maxPixels){
			largestRoi=i;
		}
	}
	roiManager("Select",largestRoi);
	getSelectionBounds(x, y, width, height);
	centerX=round(x+width/2);
	centerY=round(y+height/2);
	copyX=round(centerX-overviewSize/2);
	copyY=round(centerY-overviewSize/2);
	makeRectangle(copyX,copyY,overviewSize,overviewSize);
	run("Copy");
	newImage("saveImg", "RGB white", overviewSize, overviewSize, 1);
	saveImg=getImageID();
	run("Select None");
	run("Paste");
	run("Scale...", "x=0.25 y=0.25 interpolation=Bicubic average create title=scaledImg");
	saveAs("jpeg",saveImgPath);
	close();
	selectImage(saveImg);
	close();
	selectImage(origImg);
	close();
}

macro "create matching set lists [l]"{
	idFilePathes=split(exec("find",parentPath,"-name","sampleID.txt"),"\n");
	Array.sort(idFilePathes);
	allIdList="";
	for (i=0;i<lengthOf(idFilePathes);i++){
		//print(idFilePathes[i]);
		idLine=split(File.openAsString(idFilePathes[i]),"\n");
		//print(idLine[0]);
		//print(idLine[1]);
		//print("-------");
		
		if (lengthOf(idLine)>=2){
			thisIdListFile = parentPath+"/"+"imagesetlist_"+idLine[0]+".txt";
			dirName=split(exec("dirname",idFilePathes[i]),"\n");
			dirNameNoCr=dirName[0];
			if (indexOf(allIdList, idLine[0]+"\n")==-1){ //needs attached newline to make _1 and _11 unequal
				allIdList=""+allIdList+idLine[0]+"\n";
				File.saveString(idLine[0]+"\n"+dirNameNoCr+"\n",thisIdListFile);
			}else{
				File.append(dirNameNoCr,thisIdListFile);
			}
		}
	}
	print(allIdList);
}

macro "create ID-based mosaic [i]"{
	setBatchMode(true);
	closeAllImagesForSure();
	xMax=11;
	yMax=6;
	prefix="dl";
	imageName="AfterOverview.jpg";

	x=1;
	y=1;
	t=1;

	imagesetListFilePathes=split(exec("find",parentPath,"-name","imagesetlist*"),"\n");
	for (j=0;j<lengthOf(imagesetListFilePathes);j++){
		theseFiles=split(File.openAsString(imagesetListFilePathes[j]),"\n");
		if (lengthOf(theseFiles) >= 2){
			imagesetId = theseFiles[0]; //1st line contains ID
			print("imagesetListFilePathes["+j+"]="+imagesetListFilePathes[j]);
			montagePath=parentPath+"/montage_"+imagesetId+".jpg";
			print(montagePath);
			print("start time="+theseFiles[1]);
			imageCount=1;
			timestamps=newArray(lengthOf(theseFiles)); //first position (index 0) will not be used
			for (i=1;i<lengthOf(theseFiles);i++){
				currentImageParent=theseFiles[i];
				currentImagePath=currentImageParent+"/AfterOverview.jpg";
				currentImageTimeStampPath=currentImageParent+"/timestamp.txt";
				currentImageStartTimePath=currentImageParent+"/sampleID.txt";
				//startTimeRaw=split(File.openAsString(currentImageStartTimePath),"\n");
				//if (lengthOf(startTimeRaw)==2){
				//	imagesetZeroTime=startTimeRaw[1];
				//}else{
				//	imagesetZeroTime=-1;
				//}
				//print(currentImagePath);
				//print(currentImageTimeStampPath);
				
				if ((File.exists(currentImagePath)==true) && (File.exists(currentImageTimeStampPath)==true)){
					if (isValidTimePeriod(parseFloat(File.openAsString(currentImageTimeStampPath)))==true){
						startTimeRaw=split(File.openAsString(currentImageStartTimePath),"\n");
						if (lengthOf(startTimeRaw)==2){
							imagesetZeroTime=startTimeRaw[1];
						}else{
							imagesetZeroTime=-1;
							exit("error: "+currentImageParent);
						}
						print(currentImagePath);
						print(currentImageTimeStampPath);
						//zeroTime=imagesetZeroTime;
						timestamps[imageCount]=toString((parseFloat(File.openAsString(currentImageTimeStampPath))-imagesetZeroTime)/3600);
						print("t="+timestamps[imageCount]+" h");
						
						if (imageCount==1){
							open(currentImagePath);
							stackImg=getImageID();
							imageCount++;
						}else{
							open(currentImagePath);
							currentImage=getImageID();
							run("Select All");
							run("Copy");
							selectImage(stackImg);
							run("Add Slice");
							setSlice(nSlices());
							run("Paste");
							selectImage(currentImage);
							close();
							imageCount++;
							
						}
					}else{
						print("################################ MANUAL EXCLUSION OF DATAPOINT ######################");	
					}
				}
			}
			if (isOpen(stackImg)){
				//create mosaic
				selectImage(stackImg);
				slices=nSlices();
				if(slices>1){ // can't create mosaic with one image
					for (t=1;t<=slices;t++){
						setSlice(t); //index is counting from 1 here.
						run("Set Label...", "label="+toString(timestamps[t])+"_h");
					}
					rows=round(slices/5);
					cols=round(slices/rows);
					setForegroundColor(0,0,0); //make labels black
					run("Make Montage...", "columns="+cols+" rows="+rows+" scale="+scaling+" first=1 last="+slices+" increment=1 border=1 font=12 label use");
					montImg=getImageID();
					saveAs("jpeg",montagePath);
					close();
					selectImage(stackImg);
					close();
				}	
				closeAllImagesForSure();
				
			}	
		}
	}
	setBatchMode(false);
}



macro "create mosaic [m]"{
	setBatchMode(true);
	xMax=11;
	yMax=6;
	prefix="dl";
	imageName="AfterOverview.jpg";

	x=1;
	y=1;
	t=1;

	
	for (x=1;x<=xMax;x++){
		for (y=1;y<=yMax;y++){
			imgList=parentPath+"/imageName_list_"+toString(x)+"_"+toString(y)+".txt";
			montagePath=parentPath+"/montage_"+toString(x)+"_"+toString(y)+".jpg";
			if (File.exists(imgList)==true){
				File.delete(imgList);
			}
			
			print(imgList);
			timestamps=newArray(tMax);
			t=1;
			mainPath=parentPath+"/"+prefix+toString(t)+"_"+toString(x)+"_"+toString(y);
			timePath=""+mainPath+"/timestamp.txt";
			zeroTime=parseFloat(File.openAsString(timePath));
			tCount=0;
			for (t=1;t<=tMax;t++){
				mainPath=parentPath+"/"+prefix+toString(t)+"_"+toString(x)+"_"+toString(y);
				trackPath=""+mainPath+"/"+imageName;
				timePath=""+mainPath+"/timestamp.txt";
				print(trackPath);
				if(File.exists(trackPath)==true){
					File.append(trackPath, imgList);
					timestamps[tCount]=toString((parseFloat(File.openAsString(timePath))-zeroTime)/3600);
					tCount++;
				}
			}
			print(imgList);
			run("Stack From List...", "open="+imgList);
			stackImg=getImageID();
			for (t=0;t<tCount;t++){
				setSlice(t+1);
				run("Set Label...", "label="+toString(timestamps[t])+"_h");
			}
			rows=round(tMax/5);
			cols=round(tMax/rows);
			run("Make Montage...", "columns="+cols+" rows="+rows+" scale="+scaling+" first=1 last="+tMax+" increment=1 border=1 font=12 label");
			montImg=getImageID();
			saveAs("jpeg",montagePath);
			close();
			selectImage(stackImg);
			close();
			closeAllImagesForSure();
		}
	}
	setBatchMode(false);
}

macro "find single track [f]"{
	findSingleTrack("/mnt/1TBraid01/imagesets01/20140603_IFP53_fromL4_vibassay/dl1_1_1/imgseries_h264.AVI_2fps.AVI_30_54_after.jpg");
}

function findSingleTrack(thisImageFile){
	roiOutputFile=thisImageFile+"_best_track_Roi.zip";
	colorImageFile=thisImageFile+"_best_track_colored.jpg";
	outlineRoi=getOutlinePath(thisImageFile);
	
	
	roiManager("reset");
	open(thisImageFile);
	origImg=getImageID();
	open(outlineRoi);
	selectImage(origImg);
	//run("Gaussian Blur...", "sigma="+gaussSigma);
	roiManager("Select", 0);
	getSelectionBounds(x,y,width,height);
	plateCenterX=x+width/2;
	plateCenterY=y+height/2;
	//setAutoThreshold("RenyiEntropy");
	setAutoThreshold("Triangle");
	run("Analyze Particles...", "size="+minPixels+"-Infinity exclude add");
	nRois=roiManager("count");
	if (nRois>1){
		bestRoi=1; //default
		bestDistance=1e50; //infinity
		for (i=1;i<nRois;i++){
			roiManager("Select",i);
			getSelectionBounds(x,y,width,height);
			trackCenterX=x+width/2;
			trackCenterY=y+height/2;
			distance = sqrt(pow((plateCenterX-trackCenterX), 2)+pow((plateCenterY-trackCenterY), 2));
			//print("i:"+i+" dist:"+distance);
			if (distance < bestDistance){
				bestDistance=distance;
				bestRoi=i;
			}
		}
		origImg=getImageID();
		run("Select None");
		run("Copy");
		run("Internal Clipboard");
		copyImg=getImageID();
		selectImage(origImg);
		roiManager("Select",bestRoi);
		run("Make Inverse");
		setForegroundColor(255, 255, 255);
		run("Fill", "slice");
		run("Make Inverse");
		run("Create Selection");
		selectImage(copyImg);
		run("Restore Selection");
		run("RGB Color");
		setForegroundColor(255, 0, 0);
		run("Fill", "slice");
		roiManager("reset");
		roiManager("Add");
		roiManager("Save", roiOutputFile);
		roiManager("reset");
		selectImage(copyImg);
		run("Select None");
		saveAs("jpeg",colorImageFile);
		close();
		selectImage(origImg);
		close();
	}else{
		selectImage(origImg);
		run("Select All");
		setForegroundColor(150, 150, 150); //gray
		run("Fill", "slice");
		saveAs("jpeg",colorImageFile);
		close();
	}
}

macro "plot best after-tracks [p]"{
	setBatchMode(true);
	csvSuffix="summaryAfterTracks.csv";
	outputSummaryTables=split(exec("find",parentPath,"-name","*"+csvSuffix),"\n");
	for (i=0;i<lengthOf(outputSummaryTables);i++){
		if (File.exists(outputSummaryTables[i])==true){
			File.delete(outputSummaryTables[i]);
		}	
	}

	pathes=split(exec("find",parentPath,"-name","*_best_track_Roi.zip"),"\n");

	newImage("empty", "8-bit white", imgSizeX, imgSizeY, 1);
	emptyImage=getImageID();
	run("ROI Manager...");
	for (p=0;p<lengthOf(pathes);p++){
		parentDirRaw=exec("dirname",pathes[p]);
		parentDirSplit=split(parentDirRaw,"\n");
		parentDir=parentDirSplit[0];
		timestampFile=parentDir+"/timestamp.txt";
		timepointDirRaw=split(parentDir,"/");
		nameSegs=split(timepointDirRaw[lengthOf(timepointDirRaw)-1],"_");
		print(parentDir+" ------------- "+timepointDirRaw[lengthOf(timepointDirRaw)-1]);
		nameSegX="undefined";
		nameSegY="undefined";
		if (lengthOf(nameSegs)==3){
			nameSegX=nameSegs[1];
			nameSegY=nameSegs[2];
		}
		if (File.exists(timestampFile)==true){
			timestamp=parseInt(File.openAsString(timestampFile));
			roiManager("reset");
			open(pathes[p]);
			selectImage(emptyImage);
			roiManager("Select",0);
			getRawStatistics(nPixels, mean, min, max, std, histogram);
			resultString=""+nameSegX+"\t"+nameSegY+"\t"+timestamp+"\t"+nPixels;
			outputSummaryTable=parentPath+"/"+toString(nameSegX)+"_"+toString(nameSegY)+"_"+csvSuffix;
			File.append(resultString, outputSummaryTable)
		}
			
	}
	selectImage(emptyImage);
	close();
	setBatchMode(false);
	roiManager("reset");
}

macro "draw plots [d]"{
	setBatchMode(true);
	plotFiles();
	setBatchMode(false);
}

function plotFiles(){
	allFiles=getFileList(parentPath);
	rawData="";
	for(f=0;f<lengthOf(allFiles);f++){
		if (endsWith(allFiles[f],"summaryAfterTracks.csv")==true){
			summaryFile=parentPath+"/"+allFiles[f];
			rawData+=File.openAsString(summaryFile);
		}
	}
	print(rawData);
	rawLines=split(rawData,"\n");
	numberEntries=lengthOf(rawLines);
	timestamps=newArray(numberEntries);
	areas=newArray(numberEntries);
	for (e=0;e<numberEntries;e++){
		cols=split(rawLines[e],"\t");
		timestamps[e]=parseInt(cols[2]);
		areas[e]=parseInt(cols[3]);
	}
	Array.getStatistics(timestamps, minT, maxT, mean, stdDev);
	Array.getStatistics(areas, minA, maxA, mean, stdDev);
	
	for(f=0;f<lengthOf(allFiles);f++){
		if (endsWith(allFiles[f],"summaryAfterTracks.csv")==true){
			summaryFile=parentPath+"/"+allFiles[f];
			plotFile(summaryFile,minT,maxT,minA,maxA,allFiles[f]);
		}
	}
}

function plotFile(summaryFile,minT,maxT,minA,maxA,plotTitle){
	rawData=File.openAsString(summaryFile);
	rawLines=split(rawData,"\n");
	numberEntries=lengthOf(rawLines);
	timestamps=newArray(numberEntries);
	areas=newArray(numberEntries);
	sortedTimestamps=newArray(numberEntries);
	sortedAreas=newArray(numberEntries);
	for (e=0;e<numberEntries;e++){
		cols=split(rawLines[e],"\t");
		timestamps[e]=(parseInt(cols[2])-minT)/3600;
		areas[e]=parseInt(cols[3]);
	}
	sortKey=Array.rankPositions(timestamps);
	for (i=0;i<numberEntries;i++){
		sortedTimestamps[i]=timestamps[sortKey[i]];
		sortedAreas[i]=areas[sortKey[i]];
	}
	Plot.create(plotTitle, "time [h]", "track area [px]", sortedTimestamps, sortedAreas);
	Plot.setLimits(0,(maxT-minT)/3600,minA,maxA);
	Plot.setJustification("center");
	Plot.addText(plotTitle, 0.2, 0);
	Plot.setColor("red");
	Plot.show();
	plotWindow=getImageID();
	plotFileName=summaryFile+"_plot.png";
	Fit.doFit("y = a*exp(b*x)", sortedTimestamps, sortedAreas);
  	RodbardEquation = "y = d+(a-d)/(1+pow((x/c),b))";
  	polynomial = "y=a+b*x+c*pow(x,2)+d*pow(x,3)+e*pow(x,4)+f*pow(x,5)";
  	initialGuesses = newArray(0, 0, 0, 0, 0, 0);
  	Fit.doFit(polynomial, sortedTimestamps, sortedAreas, initialGuesses);
  	Fit.plot;
	curveWindow=getImageID();
	selectImage(plotWindow);
	rename("0");
	selectImage(curveWindow);
	rename("1");
	run("Images to Stack", "name=Stack title=[] use");
	stackImg=getImageID();
	run("Make Montage...", "columns=2 rows=1 scale=1 first=1 last=2 increment=1 border=1 font=12");
	saveAs("png",plotFileName);
	close();
	selectImage(stackImg);
	close();
}

function isValidTimePeriod(thisTimeStamp){
	validity=true;
	for (n=0;n<lengthOf(timeExclude);n+=2){
		if((thisTimeStamp>timeExclude[n])&&(thisTimeStamp<timeExclude[n+1])){
			validity=false;
		}
	}
	return validity;	
}

function makeHTMLoverview(){
	htmlViewerPath=parentPath+"/0ImageViewer.htm";
	createHTMLheader(htmlViewerPath);
	print("creating HTML viewer for montage images...");
	for (g=0;g<lengthOf(groupIDs);g++){
		pathes=split(exec("find",parentPath,"-name","montage_"+groupIDs[g]+"*.jpg"),"\n");
		if (lengthOf(pathes)>1){
			Array.sort(pathes);
		}

		for (l=0;l<lengthOf(pathes);l++){
			print(pathes[l]);
			fileString=split(pathes[l],"/");
			fileName="";
			if (lengthOf(fileString)>1){
				fileName=fileString[lengthOf(fileString)-1];
			}
			print(fileName);
			
			hrefString="<a href=\""+fileName+"\">"+substring(fileName, 8, lengthOf(fileName)-4)+"</a><br>";
			File.append(hrefString,htmlViewerPath);
		}	
	}
	createHTMLbottom(htmlViewerPath);
	print("... done");
}

function createHTMLheader(htmlViewerPath){
	File.saveString("<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">",htmlViewerPath);
	File.append("<html><head>",htmlViewerPath);
	File.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">",htmlViewerPath);
	File.append("<meta name=\"Author\" content=\"J. Hench, G. Schweighauser\">",htmlViewerPath);
	File.append("<title>image viewer</title>",htmlViewerPath);
	File.append("<base target=\"imageFrame\">",htmlViewerPath);
	File.append("<script>",htmlViewerPath);
	File.append("if(window == window.top)",htmlViewerPath);
	File.append("{",htmlViewerPath);
	File.append("var address=window.location;",htmlViewerPath);
	File.append("var s=\'<html><head><title>image viewer</title></head>\'+",htmlViewerPath);
	File.append("\'<frameset cols=\"15%,85%\" frameborder=\"4\" onload=\"return true;\" onunload=\"return true;\">\'+",htmlViewerPath);
	File.append("\'<frame src=\"\'+address+\'?\" name=\"indexframe\">\'+",htmlViewerPath);
	File.append("\'<frame src=\"file:///\" name=\"imageFrame\">\'+",htmlViewerPath);
	File.append("\'</frameset>\'+",htmlViewerPath);
	File.append("\'</html>\';",htmlViewerPath);
	File.append("document.write(s);",htmlViewerPath);    
	File.append("}",htmlViewerPath);
	File.append("</script>",htmlViewerPath);
	File.append("</head>",htmlViewerPath);
	File.append("<body text=\"#000000\" bgcolor=\"#C0C0C0\" link=\"#0000FF\" vlink=\"#8154D1\" alink=\"#ED181E\">",htmlViewerPath);
}

function createHTMLbottom(htmlViewerPath){
	File.append("</body>",htmlViewerPath);
	File.append("</html>",htmlViewerPath);	
}
