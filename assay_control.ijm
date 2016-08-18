//*************************************************************
//assay_control
//robot assisted plate imaging device - RAPID
//By Jürgen Hench & Gabriel Schweighauser
//2015
//*************************************************************

var VERSION = 0.9; //version and number of camera is written in version.txt through psmag01.sh, increase this number if something changes in this script or psmag01.lua

//robot variables
var KARELchangeRegVal="/home/user/applications/RAPID/robot/KARELchangeRegVal.sh";

//register values
//robot programs
var P_TO_A=1;
var P_FROM_A=2;
var RESET = 5;
var PUMP_ON = 6;

//robot numeric registers
var X_PLATE=2;
var Y_PLATE=3;
var Z_PLATE=5; 
var NUM_LAYERS=12;

var TODO=11;


//camera variables

var CAMSERIALS=newArray('0971C5B47AA949D7A4FD6038C1AD2B62','EBF3860AA5DF4791B466A9AF39503D26','1955DD886CB34783993370E6B572FDBA','860869D768724772A766819D1BAD8411');
//var CAMSERIALS=newArray('0971C5B47AA949D7A4FD6038C1AD2B62','B53A9EACCA6A4DAEAFE6E7CD227FC887','1955DD886CB34783993370E6B572FDBA','860869D768724772A766819D1BAD8411');

var CAMBUS=newArray(CAMSERIALS.length);
var CAMSER; //camera serial number which recorded the set, is written to camera.txt through psmag01.sh
var CAMPOS; //position on which the plate was recorded
var PTPCAM="/home/user/applications/RAPID/ptpcam/ptpcam";
var CMD; //used to execute non blocking shell scripts
var CAM;

var DOWNDIR = "/mnt/4TBraid02/20160810_vibassay_set10/dl";

var TARGETDIR;
var SAMPLEID;
var TIMESTAMP=0;

//assay variables
var TABLEFILENAME="/home/user/applications/RAPID/sampleTable_20160810.csv";
var CURRENTSAMPLEID;
var CURRENTSAMPLEZEROTIME;
var MAXY=7; //for test purposes, set x,y limits to 2,2 default: Y=7, X=10
var MAXX=10;
var MAXZ=4; 
var STACKREVERSED = true;
var STACKDURATION = 317; //at 10% speed, measured for set 9

macro "upload psmag01.lua [u] "{
	initCameras();
	for (i = 0; i < CAMBUS.length; i++){ 
		r = exec("/home/user/applications/RAPID/ptpcam/upload_psmag01_arg.sh", CAMBUS[i]);
		print(r);
	}

}
macro "init cameras [i]"{
	initCameras();
	
}

macro "setup cameras [f]"{
	for (i = 0; i < CAMBUS.length; i++){ 
		r = exec("/home/user/applications/RAPID/ptpcam/setfoc_arg.sh", CAMBUS[i]);
		print(r);
	}
	
}
macro "check cameras [c]"{
	checkCameras();
	
}
macro "reboot [r]"{
	initCameras();
	rebootCameras();
	
}
macro "start recording [s] "{
    //delete all busy_*.lck files in /tmp/
    files = getFileList("/tmp/");
		for (i=0; i<files.length; i++){
			if (indexOf("/tmp/"+files[i], "busy_") != -1){
				File.delete("/tmp/"+files[i]);
            } 
        }

    

    //start of macro
    Dialog.create("Setup");
    Dialog.addMessage("Please enter x and y coordinates \n indicating the start position of the assay");
    Dialog.addNumber("x-coordinate", 1);
    Dialog.addNumber("y-coordinate", 1);
    Dialog.addMessage("note: false corresponds to 4-3-2-1 from top to bottom");
    Dialog.addCheckbox("reversed", false);
    Dialog.show();
    startX = Dialog.getNumber();
    startY = Dialog.getNumber();
    STACKREVERSED = Dialog.getCheckbox();
    

	initCameras();
	//set ZMAX on robot
	robotSetRegister(NUM_LAYERS, MAXZ);

	while(true){
		for (y=startY;y<=MAXY;y++){

			for (x=startX;x<=MAXX;x++){
				while (File.exists("/home/user/pause.txt")==true){
					getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
					print("\\Update: pause active: "+dayOfMonth+"."+month+1+"."+year+"-"+hour+":"+minute+":"+second);
					wait(1000);
				}
		        	//write the current stack and reversed flag to a file in case of failure.

		     		logFile = "/home/user/applications/RAPID/currentStack.txt";
		     		if (File.exists(logFile)){
		     			File.delete(logFile);
		     		}
		     		File.append("time: " + TIMESTAMP + " x: " + x + " y: " + y + " stack reversed: " + STACKREVERSED, logFile);
		        	processStack(x,y);
			}
            		    //reset startX to 1 in case the recording was resumed
                        startX = 1;
            			rebootCameras(); //reboot every MAXX round
            			initCameras(); 
			
		}
        	//reset startY to 1 in case the recording was resumed
        	startY = 1;
		STACKREVERSED = !STACKREVERSED; //each round the stack gets flipped
	}
	
}

macro "hard reset cameras"{
	hardResetCameras();        
}
	

macro "execute CMD" {
	r = exec("sh", CMD, CAM, TARGETDIR, SAMPLEID, TIMESTAMP, VERSION, CAMSER, CAMPOS);
	//print(r);
}

//*************************************Camera functions******************************************************************

function initCameras() {
	//get bus of each camera to adress them separately
	CAMBUS=newArray(CAMSERIALS.length); //to reset the array, otherwise the error handling does not work as an invalid adress will still be present
	vendor="0x314F";
	
	r = exec(PTPCAM, "-l");
	lines=split(r, "\n");
	
	for (i=0; i < lines.length; i++){
		if (indexOf(lines[i], vendor) != -1) {
			field = indexOf(lines[i], "/");
			bus = substring(lines[i], field+1, field +4) ;
			device = "--dev=" + bus;
			camID = exec(PTPCAM, device, "-i");
			for (j=0; j < CAMSERIALS.length; j++){
				if (indexOf(camID, CAMSERIALS[j]) != -1){
					CAMBUS[j] = bus;
	
				}
				
			}
			
			
		}
	}
	
	for (i=0; i<CAMBUS.length; i++){
		print("CAM_"+i+" = " + CAMBUS[i]);
		if (CAMBUS[i] == 0){
			print("camera "+i+" could not connect...");
			break;

		}
	}	

	
	
}

function checkCameras(){
	//check if all cameras are still present
	print("checking if all cameras present");
	vendor="0x314F";
	r = exec(PTPCAM, "-l");
	lines=split(r, "\n");
	numCameras = 0;
	for (i=0; i<lines.length; i++){
		if (indexOf(lines[i], vendor) != -1) {
			numCameras++;
		}
		
	}
	
	if (numCameras != CAMBUS.length){
		//reset cameras
		robotSetRegister(TODO,VIB_5S);
		
		//remove old lock files
		files = getFileList("/tmp/");
		for (i=0; i<files.length; i++){
			if (indexOf("/tmp/"+files[i], "busy_") != -1){
				File.delete("/tmp/"+files[i]);
				//print("/tmp/"+files[i]);
			}
		}
		//re-initialize cameras after resetting
		initCameras();
	} else {
		print("all cameras ready!");
	}
	
}

function checkCamera(camBus){
	print("checking if camera " + camBus +" is still running");

	device = "--dev=" + CAMBUS[camBus];
	camID = exec(PTPCAM, device, "-i");
	if (indexOf(camID, CAMSERIALS[camBus]) == -1){
		print("camera " + camBus + " could not connect, try to reset camera");
	        //remove lock file then wait for all cameras to finish and reset.
	        File.delete("/tmp/busy_" + CAMBUS[camBus] + ".lck");
		
		
	        //wait for all cameras to finish and performs a hard reset/re-initialization
		hardResetCameras();
	       	
	       	

	} else {
		print("camera " + camBus + " ready!");
	}
	
}

function rebootCameras(){
	//only reboot if cameras ar "free", busy.lck is touched/removed in shell script. NOTE there is a seperate lock file for each camera.
	
	do {
	        lock = false;        
	        for (k=0; k<CAMBUS.length; k++){
	            if (File.exists("/tmp/busy_"+CAMBUS[k] + ".lck")){
	                lock = true;            
	            }        
	        }
			wait(5000);	
	} while (lock);
	
	print("rebooting cameras ...");
	for (i = 0; i < CAMBUS.length; i++){ 
		r = exec("/home/user/applications/RAPID/ptpcam/rebootCam_arg01.sh", CAMBUS[i]);
		print(r);
	}
    wait(10000); 
}

function hardResetCameras(){
	do {
		lock = false;        
	        for (i=0; i<CAMBUS.length; i++){
	            if (File.exists("/tmp/busy_"+CAMBUS[i] + ".lck")){
	                lock = true;            
	            }        
	        }
			wait(3000);	
	} while (lock);
	 
	 //hard resets cameras by interrupting of power
       	robotSetRegister(TODO,RESET);
	wait(10000); //reset will shut power for 5s
	
       	//delete all images from all cameras
       	for (j=0; j<CAMBUS.length; j++){
       		r = exec("/home/user/applications/RAPID/ptpcam/deleteImages_arg.sh", CAMBUS[j]);
		print(r);
       	}
       	initCameras();
       	rebootCameras();  //recover from crash
       	initCameras();
       	
}

function recordAssay(x,y,z){
    //psmag01_arg.sh does everything from recording to downloading and adding sampleID and timestamp
	CMD="/home/user/applications/RAPID/ptpcam/psmag01_arg.sh"; //usage: ./psmag01_arg.sh [cameraBus] [targetDir] [sampleID] [timestamp] [verion] [camera serial number] [record position]
	CAM = CAMBUS[z];
    	TARGETDIR = DOWNDIR+toString(TIMESTAMP)+"_"+toString(x)+"_"+toString(y)+"_" + toString(z);
	SAMPLEID=CURRENTSAMPLEID+"\n"+CURRENTSAMPLEZEROTIME;
	CAMSER = CAMSERIALS[z];
	CAMPOS = z;
	doCommand("execute CMD"); // ./psmag01_arg.sh CAM TARGETDIR SAMPLEID TIMESTAMP VERSION CAMSER CAMPOS

}

//********************************** robot functions *****************************************
function robotSetRegister(registerNumber,registerValue){
	a=exec(KARELchangeRegVal,registerNumber,registerValue);
	print(a);
}

function processStack(x,y){
	currentStack = parseCsvTable(TABLEFILENAME,x,y); //returns array with plates of stack x,y in the order specified in the table


    
	print("current stack: "+x+","+y+" reversed stacks: " + STACKREVERSED);
	if (currentStack[0]!=0){ //0 indicates an empty stack
		robotSetRegister(X_PLATE,x);
		robotSetRegister(Y_PLATE,y);
		//process the stack
		for (z=MAXZ-1; z>=0; z--){ //plates are picked from the top
			robotSetRegister(Z_PLATE,z+1); //robot z stack starts with 1
			robotSetRegister(TODO,P_TO_A);
			waitForRobotWhileRunning();
		        //start recording
		        TIMESTAMP = parseInt(exec("/home/user/applications/RAPID/robot/unixTime.sh"));	
		        //get current plate ID, check if order is reversed
		        if (STACKREVERSED){ 
		                z_plate = z; 
		        } else {
		               z_plate = MAXZ - z; //invert z index if stack is in normal order as currentStack goes from top to bottom
		               z_plate -= 1;               
		        }
		           
		            
		        sampleField=split(currentStack[z_plate],"/"); //delimiter between ID and UNIX time
			if (lengthOf(sampleField)==2){
				CURRENTSAMPLEID=sampleField[0];
				CURRENTSAMPLEZEROTIME=sampleField[1];
			}
		            	
		       	while (File.exists("/tmp/busy_"+CAMBUS[z]+".lck")){ // /tmp/busy_$1.lck indicates if camera is still being in use (recording AND downloading)
			        wait(5000);
			}
			checkCamera(z);            
		        recordAssay(x,y,z);
				
		
		}

        	for (z=MAXZ-1; z>=0; z--){
            	//make sure camera has finished before removing the plate
           		while (File.exists("/tmp/busy_rec_"+CAMBUS[z]+".lck")){   // /tmp/busy_rec_$1.lck is deleted as soon as the recording stops
                		wait(5000);
            		}
			z_plate = z+1; //zstack goes from 1-4
        		robotSetRegister(Z_PLATE,z_plate);
			robotSetRegister(TODO,P_FROM_A);
			waitForRobotWhileRunning();
        }

		
	} else {
		print("waiting "+STACKDURATION+"s and switching pump on");
		robotSetRegister(TODO,PUMP_ON);
		wait(STACKDURATION*1000);
		 	
	}
	//print("done with "+CURRENTSAMPLEID);
	print("------------------");
}

function waitForRobotWhileRunning(){
	//as a test, replace actual robot movements with wait
	a=exec("/home/user/applications/RAPID/robot/wait_while_running.sh");
	print(a);
	//wait(15000);
}
//****************************MISC************************************************************

function parseCsvTable(tableFileName,x,y){

    linesTable=split(File.openAsString(tableFileName),"\n");

    //slice through xy to get arrays of z
    currentStack = newArray(MAXZ);
    for (i=1; i< linesTable.length; i++){ //first line contains header
	    colRaw=split(linesTable[i],"\t");
	    index = ((y-1)*MAXX) + x; 
	    currentStack[i-1] = colRaw[index];	
    }

    for (i=0; i<currentStack.length; i++){
	    print(currentStack[i]);
	
    }
	
    return currentStack; 
    		
}
