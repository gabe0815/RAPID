// robot-based time-lapse vibration assay

var KCLdo="/home/user/fanucrobot/KCLdo.sh";
var KARELchangeRegVal="/home/user/fanucrobot/KARELchangeRegVal.sh";

var x_plate=2;
var y_plate=3;
var todo=11;

var p_to_a=1;
var p_from_a=2;
var vib_on=3;
var vib_off=4;
var vib_5s=5;
var onePlateDuration = 181; //determine when changing setup!
var downloadDestination = "/mnt/1TBraid01/imagesets01/20150508_vibassay_continous/dl"

var testrun = false;
var tableFileName="/mnt/1TBraid01/imagesets01/sampleTable.csv";
var currentSampleID;
var currentSampleZeroTime;
var maxY=7;
var maxX=10;

var cameraCycles = 0; //camera cycle counter
var cameraMaxCycles = 10; //camera should be rebooted after this amount of cycles.

macro "parseTable [p]"{
	
	for (x=1;x<=maxX;x++){
		for(y=1;y<=maxY;y++){
			parseCsvTable(tableFileName,x,y);
			print(""+x+","+y+":"+currentSampleID+" "+currentSampleZeroTime);
		}
	}
}

function parseCsvTable(tableFileName,x,yReal){
	currentSampleID="undefined";
	currentSampleZeroTime="undefined";
	y=maxY+1-yReal;
	linesTable=split(File.openAsString(tableFileName),"\n");
	//xMax=lengthOf(linesTable[0]);
	//yMax=lengthOf(linesTable);
	
	if (y<lengthOf(linesTable)){
		//print(linesTable[y]);
		colRaw=split(linesTable[y],"\t");
		if (x<lengthOf(colRaw)){
			sampleField=split(colRaw[x],"/"); //delimiter between ID and UNIX time
			if (lengthOf(sampleField)==2){
				currentSampleID=sampleField[0];
				currentSampleZeroTime=sampleField[1];
			}

		}
	}
}


macro "test camera [t]"{
	cameraRecordVideoFixedTime(); //record for 70s, will stop by iself
	wait(75000);
	cameraDownloadAndDelete("/mnt/1TBraid01/imagesets01/20140602/test2");
}

macro "main [m]"{
	testrun==false;
	waitForRobotWhileRunning();
	//for (t=22;t<1000;t++){
	while(true){
	t = parseInt(exec("/home/user/fanucrobot/unixTime.sh"));
		for (y=1;y<=maxY;y++){
			for (x=1;x<=maxX;x++){
				while (File.exists("/home/user/pause.txt")==true){
					print("pause active");
					wait(1000);
				}
				processPlate(t,x,y);
			}
		}
		//wait(5*60*1000);
	}
}

function robotReset(){
	a=exec(KCLdo,"reset");
	print(a);
	wait(4000);
}

function robotRunTp(TpName){
	a=exec(KCLdo,"run",TpName);
	print(a);
	wait(6000);
	a=exec("/home/user/fanucrobot/wait_while_running.sh");
	print(a);
	wait(2000);
}

function waitForRobotWhileRunning(){
	a=exec("/home/user/fanucrobot/wait_while_running.sh");
	print(a);
}

function robotSetRegister(registerNumber,registerValue){
	a=exec(KARELchangeRegVal,registerNumber,registerValue);
	print(a);
}

function cameraRefocus(){
	a=exec("/home/user/applications/ptpcam/refocus.sh");
	print(a);
}

function cameraRecordVideoFixedTime(){
	a=exec("/home/user/applications/ptpcam/psmag01.sh");
	//a=exec("/home/user/applications/ptpcam/video1m.sh");
	print(a);
	cameraCycles++;
}

function cameraReboot(){
	print("rebooting CHDK camera");
	wait(1000);
	a=exec("/home/user/applications/ptpcam/rebootCamera.sh");
	print(a);
	wait(3000);
	cameraCycles=0;
}

function cameraDownloadAndDelete(targetDir){
	setWorkingFlag(1);
	print("gphoto2 download to "+targetDir);
	a=exec("/home/user/applications/ptpcam/download_delete_rebootCam.sh "+targetDir);
	print(a);
	//check if download was succesful
	firmwarefile = targetDir + "/PS.FI2";
	if (File.exists(firmwarefile)==true){
		File.delete(firmwarefile);	
	}
	a=exec("/home/user/fanucrobot/unixTime.sh");
	print(a);
	File.saveString(a, ""+targetDir+"/timestamp.txt");
	setWorkingFlag(0);
	if (cameraCycles >= cameraMaxCycles){
		cameraReboot();
	}
}

function setWorkingFlag(i){
	workingflagfile="/home/user/workingflag.txt";
	if (i==1){
		File.saveString("working",workingflagfile);
	}else{
		if (File.exists(workingflagfile)==true){
			File.delete(workingflagfile);
		}
	}
}

macro "unixTime"{
	a=exec("/home/user/fanucrobot/unixTime.sh");
	print(a);
	targetDir="/home/user/fanucrobot";
	File.saveString(a, ""+targetDir+"/timestamp.txt");
}

macro "measure onePlateDuration [d] "{
	measureOnePlateDuration();
}
function processPlate(t,x,y){
	parseCsvTable(tableFileName,x,y);
	print("current plate: "+x+","+y+" = "+currentSampleID+" started at "+currentSampleZeroTime);
	if ((currentSampleID!="undefined") || (testrun==true)){
		robotSetRegister(x_plate,x);
		robotSetRegister(y_plate,y);
		robotSetRegister(todo,p_to_a);
		waitForRobotWhileRunning();
		cameraRecordVideoFixedTime(); //record for 70s, will stop by iself
		wait(70000+3000); //8s for camera setup until start, add 3s after modification on 2014-06-11
		//robotSetRegister(todo,vib_on);
		//robotSetRegister(todo,vib_5s);		
		//wait(5000); //vibrate for 5 s
		//robotSetRegister(todo,vib_off);
		//waitForRobotWhileRunning();
		//wait(35000);
		robotSetRegister(todo,p_from_a);
		wait(10000);
		cameraDownloadAndDelete(""+downloadDestination+toString(t)+"_"+toString(x)+"_"+toString(y)+"");
		sampleIdFile=""+downloadDestination+toString(t)+"_"+toString(x)+"_"+toString(y)+"/sampleID.txt";
		File.saveString(currentSampleID+"\n"+currentSampleZeroTime,sampleIdFile);
		waitForRobotWhileRunning();
	}else{
		print("waiting "+onePlateDuration+"s.");
		wait(onePlateDuration*1000);
		 	
	}
	print("done with "+currentSampleID);
	print("------------------");
}


function measureOnePlateDuration(){
	testrun=true;
	startTime = parseInt(exec("/home/user/fanucrobot/unixTime.sh"));
	//override global and save the old value
	origDownloadDestination = downloadDestination;
	downloadDestination = "/mnt/1TBraid01/imagesets01/calibrate/dl"
	processPlate(1,5,8);
	stopTime = parseInt(exec("/home/user/fanucrobot/unixTime.sh"));
	onePlateDuration = stopTime - startTime;
	print("onePlateDuratrion: " + onePlateDuration);
	//revert global to original value
	downloadDestination = origDownloadDestination;
	testrun=false;
}	
