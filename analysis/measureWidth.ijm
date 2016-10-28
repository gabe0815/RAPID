/* imagej script to measure worm width at several time points */

var file;
var lines;
var mosaicLines;
var counter = 0;
var mosaicCounter;

macro "open mosaic [e]" {
    if (counter == 0){
        list = File.openAsString("/mnt/4TBraid04/imagesets04/20160810_vibassay_set10_censored/list.txt");
        lines=split(list,"\n");
        nextMosaic();
    } else {
        startChar = indexOf(lines[counter], "sample_") + 7;
        endChar = indexOf(lines[counter], "_sorted");
        prefix = substring(lines[counter], 0, startChar);
        ID = substring(lines[counter], startChar, endChar);
        print("Save as: " + prefix + ID + "_measurements.csv");
        run("Summarize");
        saveAs("Results", prefix + ID + "_measurements.csv"); // /mnt/4TBraid04/imagesets04/20160919_vibassay_set12/sample_MT2426.F10_4_sorted_after_montage_tracklength.jpg
        run("Clear Results");        
        close(); 
        nextMosaic();
	}	
}

macro "set tool zoom [d]"{
    setTool("zoom");
}

macro "set tool line [s]"{
    setTool("line");
}

macro "measure [a]"{
    run("Measure");
}

macro "open next [c]"{
    openNext();
}

macro "set mosaic counter [i]"{

    close();
	Dialog.create("Set number");
	Dialog.addNumber("Enter montage number:", 1) ;
	Dialog.show();
	counter = Dialog.getNumber();
	nextMosaic();
}
function nextMosaic(){
    while (indexOf(lines[counter], "_after") == -1) {
        //print("not found, continue");        
        counter++; 
    }

    prefix = substring(lines[counter], 0,  indexOf(lines[counter], "_after") + 6);     
    mosaicFile = File.openAsRawString(prefix + "_mosaic_coordinates.txt"); 
    mosaicLines = split(mosaicFile, "\n");
    mosaicCounter = 0;
    imagePath = split(mosaicLines[mosaicCounter], ",");
    print(imagePath[0]+"/imgseries_h264.AVI_2fps.AVI_0.jpg");
    open(imagePath[0]+"/imgseries_h264.AVI_2fps.AVI_0.jpg");
    counter++;
}

function openNext(){
    close();
    mosaicCounter += 1;
    ///mnt/4TBraid04/imagesets04/20160919_vibassay_set12/dl1475598273_1_1_2/imgseries_h264.AVI_2fps.AVI_0.jpg
    imagePath = split(mosaicLines[mosaicCounter], ",");
    print(imagePath[0]+"/imgseries_h264.AVI_2fps.AVI_0.jpg");
    open(imagePath[0]+"/imgseries_h264.AVI_2fps.AVI_0.jpg");

}
