//generate mosaic and index file for future annotation


//mosaic parameters
var scaleFactor = 0.25;
var columns = 4; 
var height =  2304 * scaleFactor;
var width = 3072 * scaleFactor;
var fileList = "/media/imagesets04/20160217_vibassay_set4/sample_IFP213_52.txt";

function createMosaic(fileList) {
	//setBatchMode(true);
	file = File.openAsString(fileList);
	lines=split(file,"\n");
	//for (i=0; i<lengthOf(lines); i++){
	for (i=0; i<lengthOf(lines); i++){
		tabs = split(lines[i], "\t");
		path = substring(tabs[0], 0, lastIndexOf(tabs[0], "/") + 1);
		//print("Path: " + path + " time: " + parseInt(tabs[2])/3600);
	
		imgTracklength = exec("find", path, "-name", "*_trackarea.jpg");
		if (lengthOf(imgTracklength) == 0){
			continue; 
		}
		
		imgTracklength = substring(imgTracklength, 0, lengthOf(imgTracklength) -1);   
		open(imgTracklength);
		rename(parseInt(tabs[2])/3600);
		if (i == 0){
			//height =  getHeight() * scaleFactor;
			//width =  getWidth()  * scaleFactor;
			File.saveString(path +"," + i%columns + "," + floor(i/columns)+"\n" , fileList+"_mosaic_coordinates.txt"); 	
			
		} else {
			File.append(path +"," + i%columns + "," + floor(i/columns) , fileList+"_mosaic_coordinates.txt");
		}
		print(path +"," + i%columns + "," + floor(i/columns));
	}

	run("Images to Stack", "name=mosaic title=[] use");
	stack = getImageID();
	run("Make Montage...", "columns="+columns+" rows="+round(nSlices/4)+" scale="+scaleFactor+" first=1 last="+nSlices+" increment=1 border=0 font=30 label");
	/*
	montage = getImageID();
	saveAs("Jpeg",trackMosaic);
	close();
	selectImage(stack);
	close();
	setBatchMode(false);
	*/
}
macro "create mosaic [m] "{
	createMosaic("/media/imagesets04/20160217_vibassay_set4/sample_IFP213_52.txt");
	
}

macro "save annotations [s] "{
	file = File.openAsString(fileList+"_mosaic_coordinates.txt");
	lines=split(file,"\n");
	for (i=0; i<lengthOf(lines); i++){
		for (j=0; j<roiManager("Count"); j++){
			roiManager("Select", j);
			print(Roi.getName);
			path = split(lines[i], ",");
			if (indexOf(lines[i], Roi.getName) != -1){
				print(lines[i]);
				print("censoring " + path[0]);
				File.saveString("censored", path[0]+"censored.txt");
				break;
			} else if (File.exists(path[0]+"censored.txt")){
				File.delete(path[0]+"censored.txt");
			}
			
		}
		
		
		
	}
	roiManager("Reset");
	run("Remove Overlay");

}

macro "open annotations [o] "{
	roiManager("Reset");
	run("Remove Overlay");
	
	file = File.openAsRawString(fileList+"_mosaic_coordinates.txt");
	lines=split(file,"\n");
	for (i=0; i<lengthOf(lines); i++){
		path = split(lines[i], ",");
		if (File.exists(path[0]+"censored.txt")){
			makeRectangle(path[1]*width+50, path[2]*height + 50, width-100, height-100);
			roiManager("Add");
			roiManager("Select",roiManager("count")-1);
			roiManager("Rename",path[1]+","+path[2]);
		}
	}
	run("From ROI Manager")
	run("Show Overlay");
	run("Overlay Options...", "stroke=none width=10 fill=#660000ff apply");
}
macro "annotate images [a] " {
	
	run("Select None");
	run("Overlay Options...", "stroke=none width=10 fill=#660000ff");
	getCursorLoc(x, y, z, flags);
	xCoord = floor(x/width);
	yCoord = floor(y/height);
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
		run("From ROI Manager");
		run("Overlay Options...", "stroke=none width=10 fill=#660000ff apply");
	}
	
}
