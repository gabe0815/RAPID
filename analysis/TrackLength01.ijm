// track length analysis by Gaussian Blur and Skeletonize
//run this macro like this:
//for i in $(ls -d */) | parallel "if [ ! -f {}trackROIs.zip ]; then /mnt/1TBraid01/applications/Fiji.app/ImageJ-linux64 --allow-multiple -macro /path/to/macro.ijm {}; fi"



setBatchMode(true);

var trackGaussSigma = 5; // tested with 3072 x 2304 2016-3-21 RAPID data
var trackOutput = "trackLength.tsv" // result values
var trackROIs = "trackROIs.zip" // result ROIs
var trackVersion = "v1";

AnalyzeTrackLength(getArgument());

setBatchMode(false);
run("Quit"); //quit imageJ process after completion to release RAM.


//----------------main----------------------------
function AnalyzeTrackLength(sourceDir){
    //get all paths    
    imgBefore = exec("find", sourceDir, "-name", "*_before.jpg");
	imgBefore = substring(imgBefore, 0, lengthOf(imgBefore) -1); //remove newline
    imgAfter =  exec("find", sourceDir, "-name", "*_after.jpg");	
    imgAfter = substring(imgAfter, 0, lengthOf(imgAfter) -1);
    imgOverlay = exec("find", sourceDir, "-name", "*_overlay.jpg");
    imgOverlay = substring(imgOverlay, 0, lengthOf(imgOverlay) -1);   

	
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
	roiManager("Save",""+sourceDir+trackROIs);
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
	File.append(""+description+"\t"+toString(nPixelsLength)+"\t"+toString(nPixelsArea), ""+sourceDir+trackOutput);
	close();
}
