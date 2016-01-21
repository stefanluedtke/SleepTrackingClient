var accelDataPath;
var hrDataPath;
var ax;
var ay;
var az;
var saveAccel;

window.onload = function () {

    // add eventListener for tizenhwkey
    document.addEventListener('tizenhwkey', function(e) {
        if(e.keyName == "back")
	try {
	    tizen.application.getCurrentApplication().exit();
	} catch (ignore) {
	}
    });


    //--------start of my code------------
    //other sensors (e.g. webapis.sensorService.getDefaultSensor("LIGHT") do not work, because of old version


    //do not go to sleep
    tizen.power.request("CPU", "CPU_AWAKE");
    
    //delete all files from documents when button is pressed
    document.getElementById("delete_btn").onclick = deleteFiles;
    
    
    //read acceleration values when motion event occurs
    //TODO get average acceleration?
    window.addEventListener('devicemotion', function(e) {
        if(saveAccel){
        	ax = e.acceleration.x;
        	ay = e.acceleration.y;
        	az = e.acceleration.z;
    		saveSensorData();
    	}
    });
    
       
   //look for checked checkboxes and initialize accordingly
   var saveIntervalId;
   document.getElementById("accel_check").onchange=function(event) {
	    var checkbox = event.target;
	    if (checkbox.checked) {
	        //local has been checked, initialize file and write data
	    	console.log("initializing local file for accel data...");
	    	initializeLocal();
	    	saveAccel=true;
//	    	saveIntervalId=setInterval(function(){ 
//	    	  saveSensorData();
//	        }, 1000);
	    	
	    } else {
	        //local has been unchecked, stop saving
	    	saveAccel=false;
	    	console.log("stopping local saving of accel");
	    	clearInterval(saveIntervalId);
	    }
	};
	
	   //look for checked checkboxes and initialize accordingly
	   var hrIntervalId;
	   document.getElementById("hr_check").onchange=function(event) {
		    var checkbox = event.target;
		    if (checkbox.checked) {
		        //local has been checked, initialize file and write data
		    	console.log("initializing local file for hr data...");
		    	initializeHr();
		    	hrIntervalId=setInterval(function(){ 
		    	  saveHrData();
		        }, 5000);
		    	
		    } else {
		        //local has been unchecked, stop saving
		    	console.log("stopping local saving of hr");
		    	clearInterval(hrIntervalId);
				window.webapis.motion.stop("HRM");
		    }
		};
	    	
    
};//end onload




//function that saves accel values
saveSensorData = function(){
    document.getElementById("xaccel").innerHTML = "X: "+ ax;
    document.getElementById("yaccel").innerHTML = "Y: "+ ay;
    document.getElementById("zaccel").innerHTML = "Z: "+ az;
	//open file and write data
	tizen.filesystem.resolve(accelDataPath,function(file){
		file.openStream("a", function(fs){
			//write data as csv
			fs.write(Date.now()+","+ax+","+ay+","+az+"\n");
			fs.close();
			}, null, "UTF-8");
	});
}

var hrSem = false;
saveHrData = function(){
	//open file and write data
	if(!hrSem){
		hrSem=true;
		window.webapis.motion.start("HRM", function(hrm) {
			document.getElementById("hr").innerHTML ="HR: "+ hrm.heartRate;
			tizen.filesystem.resolve(hrDataPath,function(file){
				file.openStream("a", function(fs){
					if(hrm.heartRate>0){
						fs.write(Date.now()+","+hrm.heartRate+"\n");
						window.webapis.motion.stop("HRM");
						hrSem=false;
					}
					fs.close();
				},null, "UTF-8");
			});
		});
	}
}

//initialize local file:
initializeLocal = function(){
	  //create new accelData-File with timestamp in /opt/usr/media/Documents
	  var accelDataName = "accelData_"+Date.now()+".csv";
	  accelDataPath = "documents/"+accelDataName;
	  console.log("using file: "+accelDataPath);
	  tizen.filesystem.resolve("documents", function(path){
		  var file = path.createFile(accelDataName);
		  file.openStream("w", function(fs){
				//write header
				fs.write("time,x,y,z\n");
				fs.close();
				}, null, "UTF-8");
	  });
}

//initialize hr file
initializeHr = function(){
	  //create new accelData-File with timestamp in /opt/usr/media/Documents
	  var hrDataName = "hrData_"+Date.now()+".csv";
	  hrDataPath = "documents/"+hrDataName;
	  console.log("using file: "+hrDataPath);
	  tizen.filesystem.resolve("documents", function(path){
		  var file = path.createFile(hrDataName);
		  file.openStream("w", function(fs){
				//write header
				fs.write("time,hr\n");
				fs.close();
				}, null, "UTF-8");
	  });
}

//delete all files from /opt/usr/media/Documents
deleteFiles = function(){
	tizen.filesystem.resolve("documents", function(dir){
		  var onListFilesSuccess = function(files) {
			    files.forEach(function(file) {
			      if (!file.isDirectory) {
			        dir.deleteFile(file.fullPath, null,null);
			      }
			    });
			  };
			  dir.listFiles(onListFilesSuccess, null);
	});
}


