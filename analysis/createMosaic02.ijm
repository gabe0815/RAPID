//generate mosaic and index file for future annotation
//mosaic parameters
var scaleFactor = 0.25;
var columns = 4; 
var height =  2304 * scaleFactor +37;  //40px is the yMargin
var width = 3072 * scaleFactor;
var file;
var lines;
var mosaic_lines;
var counter = -2 +1* 28 + 19 ; //we increment firtst
var yOffset = 70;
macro "load from list [l] "{
	list = File.openAsString("/mnt/4TBraid04/imagesets04/20160810_vibassay_set10/list.txt");
	lines=split(list,"\n");
		
}

macro "open next [n]" {
     counter++;
    open(lines[counter]);
    //run("Set... ", "zoom=25");
    wait(1000);
    setLocation(0, 0, 1500, 3000);
    roiManager("Reset");
    run("Remove Overlay");
    //filePath = "/media/imagesets04/20160311_vibassay_set5/IFP199_12_sorted";
    filePath = getInfo("image.directory") + getInfo("image.filename");
    filePath = substring(filePath, 0,  indexOf(filePath, "_montage"));
    //print(filePath);
    file = File.openAsRawString(filePath+"_mosaic_coordinates.txt");
    //print(file);	
    mosaic_lines=split(file,"\n");
	for (i=0; i<lengthOf(mosaic_lines); i++){
		path = split(mosaic_lines[i], ",");
		if (File.exists(path[0]+"/"+"censored.txt")){
			makeRectangle(path[1]*width+50, path[2]*height + yOffset, width-100, height-100);
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


macro "save annotations [s] "{
	//file = File.openAsString(fileList+"_mosaic_coordinates.txt");
	//print(file);
	for (i=0; i<lengthOf(mosaic_lines); i++){
		//remove all censored flags first, then add them
		path = split(mosaic_lines[i], ",");
		if (File.exists(path[0]+"/"+ "censored.txt")){
			File.delete(path[0]+"/"+"censored.txt");
		}
	}

	for (i=0; i<roiManager("Count"); i++){
		roiManager("Select", i);
		print(Roi.getName);
		for (j=0; j<lengthOf(mosaic_lines);j++){
			path = split(mosaic_lines[j], ",");
			if (indexOf(mosaic_lines[j], ","+Roi.getName) != -1){ //otherwise we find 1_2_3,0,0 if we look for 3,0
				print(mosaic_lines[j]);
				print("censoring " + path[0]);
				File.saveString("censored", path[0]+"/"+"censored.txt");
				break;
			}
		}
	}
	
	roiManager("Reset");
	run("Remove Overlay");
	run("Select None");
	close();
	
}

macro "print annotations [p]"{
	if (File.exists(lines[counter]+"_wrongID.txt" )){
		File.delete (lines[counter]+"_wrongID.txt" );
	}
	
	for (i=0; i<roiManager("Count"); i++){
		roiManager("Select", i);
		print(Roi.getName);
		for (j=0; j<lengthOf(mosaic_lines);j++){
			path = split(mosaic_lines[j], ",");
			if (indexOf(mosaic_lines[j], ","+Roi.getName) != -1){ //otherwise we find 1_2_3,0,0 if we look for 3,0
				print(path[0]);
				File.append(path[0], lines[counter]+"_wrongID.txt" );
				break;
			}
		}
	}
	
	roiManager("Reset");
	run("Remove Overlay");
	run("Select None");
	close();
}

macro "annotate images [a] " {
	
	run("Select None");
	run("Overlay Options...", "stroke=none width=10 fill=#660000ff");
	getCursorLoc(x, y, z, flags);
	xCoord = floor(x/width);
	yCoord = floor(y/height);
	//print("xCoord: " +xCoord + " yCoord: " + yCoord);
	makeRectangle(xCoord*width+50, yCoord*height + yOffset, width-100, height-100);
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
