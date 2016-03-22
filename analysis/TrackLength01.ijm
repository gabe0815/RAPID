// track length analysis by Gaussian Blur and Skeletonize

var trackGaussSigma = 5; // tested with 3072 x 2304 2016-3-21 RAPID data
var trackOutput = "trackLength.tsv" // result values
var trackROIs = "trackROIs.zip" // result ROIs
var trackVersion = "v1";
//var trackDemo = "/media/imagesets04/20160321_FIJI_analysis_testing/IFP213_63_mosaic_trackDemo.tsv";
//var trackMosaic = "/media/imagesets04/20160321_FIJI_analysis_testing/IFP213_50_mosaic_area_filter.jpg";
//var filePath = "/media/imagesets04/20160217_vibassay_set4/sample_IFP213_50_imagelist.txt";

//run analysis on whatever dir that is given as argument
dirPath = getArgument();
processTrack(dirPath);



macro "trackTest [t]"{
	setBatchMode(true);
	src = "/media/imagesets04/20160321_FIJI_analysis_testing/dl1455724911_2_1_1_video/";
	imgBefore = "/media/imagesets04/20160321_FIJI_analysis_testing/dl1455724911_2_1_1_video/imgseries_h264.AVI_2fps.AVI_0_25_before.jpg"
	imgAfter  = "/media/imagesets04/20160321_FIJI_analysis_testing/dl1455724911_2_1_1_video/imgseries_h264.AVI_2fps.AVI_27_54_after.jpg"
	imgOverlay = "/media/imagesets04/20160321_FIJI_analysis_testing/dl1455724911_2_1_1_video/imgseries_h264.AVI_2fps.AVI_overlay.jpg"
	AnalyzeTrackLength(src, imgBefore, imgAfter, imgOverlay);
	setBatchMode(false);
}

macro "process tracks from file [f] "{
	setBatchMode(true);
	
	//file = File.openAsString("/media/imagesets04/20160217_vibassay_set4/sample_IFP211_5_imagesList.txt");
	file = File.openAsString(filePath);
	//remove later
	File.saveString("",trackDemo);
	lines=split(file,"\n");
	
	for (i=0; i<lengthOf(lines); i++){
		imgBefore = exec("find", lines[i], "-name", "*_before.jpg");
		imgBefore = substring(imgBefore, 0, lengthOf(imgBefore) -1); //remove newline
    		imgAfter =  exec("find", lines[i], "-name", "*_after.jpg");	
		imgAfter = substring(imgAfter, 0, lengthOf(imgAfter) -1);
        	imgOverlay = exec("find", lines[i], "-name", "*_overlay.jpg");
        	imgOverlay = substring(imgOverlay, 0, lengthOf(imgOverlay) -1);   
    		src = substring(lines[i], 0, lastIndexOf(lines[i], "/"));
    		//print("imgBefore: " + imgBefore + " imgAfter: " + imgAfter + " src: " + src);
		AnalyzeTrackLength(src, imgBefore, imgAfter, imgOverlay);
	}
	//AnalyzeTrackLength(src, imgBefore, imgAfter);
	setBatchMode(false);
}

macro "assemble mosaic [m] "{
	setBatchMode(true);
	
	file = File.openAsString(filePath);
	//remove later
	File.saveString("",trackDemo);
	lines=split(file,"\n");
	
	for (i=0; i<lengthOf(lines); i++){
		imgTracklength = exec("find", lines[i], "-name", "*_trackarea.jpg");
		imgTracklength = substring(imgTracklength, 0, lengthOf(imgTracklength) -1);   
		open(imgTracklength);
	}

	run("Images to Stack", "name=Stack title=[] use");
	stack = getImageID();
	run("Make Montage...", "columns=4 rows="+round(nSlices/4)+" scale=0.25 first=1 last="+nSlices+" increment=1 border=0 font=12");
	montage = getImageID();
	saveAs("Jpeg",trackMosaic);
	close();
	selectImage(stack);
	close();
	setBatchMode(false);
}

function AnalyzeTrackLength(sourceDir, imgBefore, imgAfter, imgOverlay){
	File.saveString("trackVersion "+trackVersion+"\tlength\tarea\n", ""+sourceDir+trackOutput);
	roiManager("reset");
	open(""+imgBefore);
	resBefore = MeasureTrack(getImageID(),sourceDir,"before");
	open(""+imgAfter);
	resAfter = MeasureTrack(getImageID(),sourceDir,"after");
	//insert track length and skeleton     
	open("" + imgOverlay);
	x=100; 
	y=2200;    
	setColor(255, 0, 0);
	setFont("SansSerif" , 120);
	resAfterSplit = split(resAfter, "\t");
    drawString("" + resAfterSplit[1], x, y);
    if (resAfterSplit[0] != 0){
	    //add skeleton
	    setForegroundColor(255, 0, 0);
	    roiManager("select", 2);
	    roiManager("Draw");
    }   

 	saveAs("Jpeg", imgOverlay+"_trackarea.jpg");
    	close();

	roiManager("Deselect");
	roiManager("Save",""+sourceDir+"/"+trackROIs);
	roiManager("reset");
	//remove later
	File.append(sourceDir+"\t"+resBefore+"\t"+resAfter, trackDemo);
	print(sourceDir+","+resBefore+","+resAfter);
}

function MeasureTrack(thisImage, sourceDir, description)
{
	selectImage(thisImage);
	run("32-bit");
	run("Gaussian Blur...", "sigma=" + trackGaussSigma);
    //check if there are tracks at all,otherwise thresholding will pick up noise
    getRawStatistics(nPixels, mean, min, max, std, histogram);
    if (min > 200){
        makeRectangle(1, 1, 5, 5);
        roiManager("Add");
	roiManager("Select",roiManager("count")-1);
	roiManager("Rename",description+"Area");

	makeRectangle(1, 1, 5, 5);
	roiManager("Add");
	roiManager("Select",roiManager("count")-1);
	roiManager("Rename",description+"Skeleton");
	close();
        return "0\t0"    
    }
    setAutoThreshold("Default");
	run("Convert to Mask");
	run("Create Selection");
	getRawStatistics(nPixelsArea, mean, min, max, std, histogram);
	roiManager("Add");
	roiManager("Select",roiManager("count")-1);
	roiManager("Rename",description+"Area");
	run("Skeletonize");
	run("Create Selection");
	getRawStatistics(nPixelsLength, mean, min, max, std, histogram);
	roiManager("Add");
	roiManager("Select",roiManager("count")-1);
	roiManager("Rename",description+"Skeleton");
	File.append(""+description+"\t"+toString(nPixelsLength)+"\t"+toString(nPixelsArea), ""+sourceDir+"/"+trackOutput);
	close();
	//remove this line after first test!!!
	return toString(nPixelsLength)+"\t"+toString(nPixelsArea);
}
