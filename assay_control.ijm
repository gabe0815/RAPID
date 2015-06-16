
//robot variables
var KARELchangeRegVal="/home/user/fanucrobot/KARELchangeRegVal.sh";

//register values
var p_to_a=1;
var p_from_a=2;

var x_plate=2;
var y_plate=3;

var vib_5s=5;

var todo=11;


//camera variables
var camSerials=newArray('B0A8859584994AFFB9EFAF7AB6382F77','B53A9EACCA6A4DAEAFE6E7CD227FC887','1955DD886CB34783993370E6B572FDBA','860869D768724772A766819D1BAD8411');
var camBus=newArray(camSerials.length);
var ptpcam="/home/user/applications/ptpcam/ptpcam";
var cmd; //used to execute non blocking shell scripts
var cam;

macro "upload psmag01.lua [u] "{
	initCameras();
	for (i = 0; i < camBus.length; i++){ 
		r = exec("/home/user/fanucrobot/upload_psmag01_arg.sh", camBus[i]);
		print(r);
	}

}
macro "init cameras [i]"{
	initCameras();
	
}

macro "check cameras [c]"{
	checkCameras();
	
}
macro "reboot [r]"{
	initCameras();
	rebootCameras();
	
}
macro "start recording [s] "{
	/*make sure, busy file is removed. It is set in imaging shell script to prevent rebooting while still busy. This could probably be omitted, as it is deleted from the shell script after it has finished.
	*/
	//File.delete("/tmp/busy.lck");	
	
	initCameras();
	
	
	//start of main loop
	for (i=1; i < 10000; i++){
		//make sure all cameras are still running
		
		
		print("round number: " + i);
		//start imaging
		for (j=0; j<camBus.length; j++){
			//cmd="/home/user/mac/Users/jhench/Documents/sync/lab_journal/2015/data201502/ptpcam_multicam/psmag01_arg.sh";
			cmd="/home/user/fanucrobot/psmag01_arg.sh";
			cam = camBus[j];
			print(cmd+" " + cam);
			lock = "/tmp/busy_"+camBus[j]+".lck";
			while (File.exists(lock)){
				wait(5000);
			}
			doCommand("execute cmd");
			wait(2000); //record simulatenously to check if vibration on one affects the other plate
		}
		
		if (i % 10 == 0){
			//wait(70000);
			rebootCameras();
			wait(10000);
			initCameras();
		}
		wait(600000); //start recording every 10 min
		
		
	}
}

macro "execute cmd" {
	r = exec("sh", cmd, cam);
	//print(r);
}

//*************************************Camera functions******************************************************************

function initCameras() {
	//get bus of each camera to adress them separately
	camBus=newArray(camSerials.length); //to reset the array, otherwise the error handling does not work as an invalid adress will still be present
	vendor="0x314F";
	
	r = exec(ptpcam, "-l");
	lines=split(r, "\n");
	
	for (i=0; i < lines.length; i++){
		if (indexOf(lines[i], vendor) != -1) {
			field = indexOf(lines[i], "/");
			bus = substring(lines[i], field+1, field +4) ;
			device = "--dev=" + bus;
			camID = exec(ptpcam, device, "-i");
			for (j=0; j < camSerials.length; j++){
				if (indexOf(camID, camSerials[j]) != -1){
					camBus[j] = bus;
	
				}
				
			}
			
			
		}
	}
	
	for (i=0; i<camBus.length; i++){
		print("cam_"+i+" = " + camBus[i]);
		if (camBus[i] == 0){
			print("initialization failed ...");
			exit("camera "+i+" could not connect...");
			break;
			//return 1;	
		} else {
			//print("sucess!");

		}
	}	

	
	
}

function checkCameras(){
	//check if all cameras are still present
	print("checking if all cameras present");
	vendor="0x314F";
	r = exec(ptpcam, "-l");
	lines=split(r, "\n");
	numCameras = 0;
	for (i=0; i<lines.length; i++){
		if (indexOf(lines[i], vendor) != -1) {
			numCameras++;
		}
		
	}
	if (numCameras != camBus.length){
		//reset cameras
		robotSetRegister(todo,vib_5s);
		
		//remove old lock files
		files = getFileList("/tmp/");
		for (i=0; i<files.length; i++){
			if (indexOf("/tmp/"+files[i], "busy_") != -1){
				File.delete("/tmp/"+files[i]);
				print("/tmp/"+files[i]);
			}
		}
	}
	
}


function rebootCameras(){
	//only reboot if cameras ar "free", busy.lck is touched/removed in shell script. NOTE there is a seperate lock file for each camera.
	
	do {
	        lock = false;        
	        for (k=0; k<camBus.length; k++){
	            if (File.exists("/tmp/busy_"+camBus[k] + ".lck")){
	                lock = true;            
	            }        
	        }
			wait(5000);	
	} while (lock);
	
	print("rebooting cameras ...");
	for (i = 0; i < camBus.length; i++){ 
		//chdkCMD=" --dev="+camBus[j]+" --chdk=\"lua sleep(2000) reboot()\"";
		//r = exec("/home/user/mac/Users/jhench/Documents/sync/lab_journal/2015/data201502/ptpcam_multicam/rebootCam_arg01.sh", camBus[i]);
		r = exec("/home/user/fanucrobot/rebootCam_arg01.sh", camBus[i]);
		//r = exec(ptpcam, chdkCMD);
		print(r);
	}
}

//********************************** robot functions *****************************************
function robotSetRegister(registerNumber,registerValue){
	a=exec(KARELchangeRegVal,registerNumber,registerValue);
	print(a);
}

