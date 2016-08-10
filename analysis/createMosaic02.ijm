//generate mosaic and index file for future annotation
//mosaic parameters
var scaleFactor = 0.25;
var columns = 4; 
var height =  2304 * scaleFactor;
var width = 3072 * scaleFactor;

var file
macro "save annotations [s] "{
	//file = File.openAsString(fileList+"_mosaic_coordinates.txt");
	//print(file);
	lines=split(file,"\n");
	for (i=0; i<lengthOf(lines); i++){
		//remove all censored flags first, then add them
		path = split(lines[i], ",");
		if (File.exists(path[0]+"/"+ "censored.txt")){
			File.delete(path[0]+"/"+"censored.txt");
		}
	}

	for (i=0; i<roiManager("Count"); i++){
		roiManager("Select", i);
		print(Roi.getName);
		for (j=0; j<lengthOf(lines);j++){
			path = split(lines[j], ",");
			if (indexOf(lines[j], ","+Roi.getName) != -1){ //otherwise we find 1_2_3,0,0 if we look for 3,0
				print(lines[j]);
				print("censoring " + path[0]);
				File.saveString("censored", path[0]+"/"+"censored.txt");
				break;
			}
		}
	}
	
	roiManager("Reset");
	run("Remove Overlay");
	run("Select None");
	
}

macro "open annotations [o] "{
    roiManager("Reset");
    run("Remove Overlay");
    //filePath = "/media/imagesets04/20160311_vibassay_set5/IFP199_12_sorted";
    filePath = getInfo("image.directory") + getInfo("image.filename");
    filePath = substring(filePath, 0,  indexOf(filePath, "_montage"));
    //print(filePath);
    file = File.openAsRawString(filePath+"_mosaic_coordinates.txt");
    //print(file);	
    lines=split(file,"\n");
	for (i=0; i<lengthOf(lines); i++){
		path = split(lines[i], ",");
		if (File.exists(path[0]+"/"+"censored.txt")){
			makeRectangle(path[1]*width+50, path[2]*height + 50, width-100, height-100);
			roiManager("Add");
			roiManager("Select",roiManager("count")-1);
			roiManager("Rename",path[1]+","+path[2]);
		}
	}
	if (roiManager("Count")!=0){
		run("From ROI Manager");
		run("Show Overlay");
		run("Overlay Options...", "stroke=none width=10 fill=#660000ff apply");
	}
	run("Select None");
}
macro "annotate images [a] " {
	
	run("Select None");
	run("Overlay Options...", "stroke=none width=10 fill=#660000ff");
	getCursorLoc(x, y, z, flags);
	xCoord = floor(x/width);
	yCoord = floor(y/height);
	//print("xCoord: " +xCoord + " yCoord: " + yCoord);
	makeRectangle(xCoord*width+50, yCoord*height + 50, width-100, height-100);
	roiManager("Add");
	roiManager("Select",roiManager("count")-1);
	roiManager("Rename",xCoord+","+yCoord);
	//run("Add Selection...", "fill=#660000ff");
	//run("Select All");
	run("Add Selection...");
	run("Show Overlay");
	print("selected image: " + xCoord + ", " + yCoord);

	
}

macro "remove annotation [r] "{
	getCursorLoc(x, y, z, flags);
	for (i=0; i<roiManager("count"); i++){
		roiManager("Select", i);
		if (selectionContains(x,y)){
			roiManager("Delete");
		}
		run("Remove Overlay");
		if (roiManager("Count")!=0){
			run("From ROI Manager");
			run("Overlay Options...", "stroke=none width=10 fill=#660000ff apply");
		}
		
	}

}
