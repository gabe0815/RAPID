//generate mosaic and index file for future annotation
//mosaic parameters
var scaleFactor = 0.25;
var columns = 4; 
var height =  2304 * scaleFactor +37;  //40px is the yMargin
var width = 3072 * scaleFactor;
var file;
var lines;
var mosaic_lines;
var counter = -2+1; //we increment firtst 195_39
//var counter = -1; //we increment firtst
//var counter = -1;
var yOffset = 70;
var description;

macro "set image number [i]"{
	close();
	Dialog.create("Set number");
	Dialog.addNumber("Enter montage number:", 1) ;
	Dialog.show();
	counter = Dialog.getNumber();
	counter -= 2;
	openNext();
}	

function openNext(){
    counter++;
    print("opening " + lines[counter]);
    open(lines[counter]);
    //run("Set... ", "zoom=25");
    wait(1000);
    setLocation(0, 0, 2000, 4000);
    roiManager("Reset");
    run("Remove Overlay");
    //imagePath = "/mnt/4TBraid04/imagesets04/20160810_vibassay_set10_censored/sample_N2.FUdR.10_15_sorted_after_montage_tracklength.jpg";
    imagePath = getInfo("image.directory") + getInfo("image.filename");
    prefix = substring(imagePath, 0,  indexOf(imagePath, "_montage"));
    //print(filePath);

    file = File.openAsRawString(prefix+"_mosaic_coordinates.txt");
    description = substring(imagePath, indexOf(imagePath,"sorted_") +7 ,  indexOf(imagePath, "_montage")) ; // /mnt/4TBraid04/imagesets04/20160810_vibassay_set10_censored/sample_N2.FUdR.40_7_sorted_before_montage_tracklength.jpg
     //print(file);	
    mosaic_lines=split(file,"\n");
	for (i=0; i<lengthOf(mosaic_lines); i++){
		path = split(mosaic_lines[i], ",");
		//print(path[0]);
		
		if (File.exists(path[0]+"/"+"censored.txt")){
			censoredFile =  File.openAsRawString(path[0] +"/censored.txt");
			//print("censored");
			if (indexOf(censoredFile, description)  != -1){
				makeRectangle(path[1]*width+50, path[2]*height + yOffset, width-100, height-100);
				roiManager("Add");
				roiManager("Select",roiManager("count")-1);
				roiManager("Rename",path[1]+","+path[2]);
			}
		}
		
	}
	if (roiManager("Count")!=0){
		run("From ROI Manager");
		run("Show Overlay");
		run("Overlay Options...", "stroke=none width=10 fill=#660000ff apply");
	}
	
    run("Select None");
}

macro "load from list [l] "{
	list = File.openAsString("/mnt/4TBraid04/imagesets04/20160810_vibassay_set10_censored/list.txt");
	lines=split(list,"\n");
		
}

macro "close [e]" {
	close();
	openNext();
}



macro "open next [n]" {
    openNext();
		
}


macro "save annotations [a] "{
	//file = File.openAsString(fileList+"_mosaic_coordinates.txt");
	//print(file);
	for (i=0; i<lengthOf(mosaic_lines); i++){
        before = 0;
        after = 0;
		//remove all censored flags first, then add them
		path = split(mosaic_lines[i], ",");
		if (File.exists(path[0]+"/censored.txt")){
			censoredFile = File.openAsRawString(path[0]+"/censored.txt");
            File.delete(path[0]+"/"+ "censored.txt");
            if ((indexOf(censoredFile, "before") != -1) && (description != "before")) {
                before = 1;
            }
            if ((indexOf(censoredFile, "after") != -1) && (description != "after")) {
                after = 1;            
            }
            
            //write a new file with the remaining censor flag
            if (before == 1){
                File.saveString("before\t1\n", path[0]+"/censored.txt");
            } else if (after == 1) {
                File.saveString("after\t1\n", path[0]+"/censored.txt");
            }
			
		}
	}

	for (i=0; i<roiManager("Count"); i++){
		roiManager("Select", i);
		print(Roi.getName);
		for (j=0; j<lengthOf(mosaic_lines);j++){
			path = split(mosaic_lines[j], ",");
			if (indexOf(mosaic_lines[j], ","+Roi.getName) != -1){ //otherwise we find 1_2_3,0,0 if we look for 3,0
				//print(mosaic_lines[j]);
				//print("censoring " + path[0]);
				File.append(description +"\t1", path[0]+"/"+"censored.txt");
				break;
			}
		}
	}
	
	roiManager("Reset");
	run("Remove Overlay");
	run("Select None");
	close();
	openNext();
}

macro "print annotations [p]"{
	if (File.exists(lines[counter]+"_wrongID.txt" )){
		File.delete(lines[counter]+"_wrongID.txt" );
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
	openNext();
}

macro "annotate images [d] " {
	
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
	//print("selected image: " + xCoord + ", " + yCoord);

	
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
