var accelDataPath;
var hrDataPath;
var accelData;
var orienData;
var saveAccel;
var saveOrien;
var currPower;


window.onload = function () {

    // add eventListener for tizenhwkey
//    document.addEventListener('tizenhwkey', function(e) {
//        if(e.keyName == "back")
//	try {
//	    tizen.application.getCurrentApplication().exit();
//	} catch (ignore) {
//	}
//    });


    //--------start of my code------------
    //am besten: web services, aber auch erst ab tizen 2.3
    
	//logging
	var logName = "log_"+Date.now()+".txt";
	var logPath = "documents/"+logName;
	  tizen.filesystem.resolve("documents", function(path){
		  var file = path.createFile(logName);
	  });
	  
	  window.onerror = function (msg, url, num) {
		  tizen.filesystem.resolve(logPath, function(file){
	  		  file.openStream("a", function(fs){
	  				fs.write("Error: " + msg + "\nURL: " + url + "\nLine: " + num+"\n");
	  				fs.close();
	  				}, null, "UTF-8");
	  	  });
		    return true;
		};
	//end of logging
		
		
	
    accelData=[];
    orienData=[];
    currPower=0;

    saveAccel=false;
    saveOrien=false;
    //do not go to sleep
    tizen.power.request("CPU", "CPU_AWAKE");
    
    //delete all files from documents when button is pressed
    document.getElementById("delete_btn").onclick = deleteFiles;
    
    
    //read acceleration values when motion event occurs
    //TODO get average acceleration?
    window.addEventListener('devicemotion', function(e) {
    	if(saveAccel){
            	accelData.push({time: Date.now(), x: e.acceleration.x, y: e.acceleration.y, z: e.acceleration.z});
            	if(accelData.length>25){
            		saveSensorData();
            	}
    	}
    });
    
    window.addEventListener('deviceorientation', function(e) {
    	if(saveOrien){
            	orienData.push({time: Date.now(), alpha: e.alpha, beta: e.beta, gamma: e.gamma});
            	if(orienData.length>17){
            		saveOrientation();
            	}
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
	    	accelData=[];
//	    	saveIntervalId=setInterval(function(){ 
//	    	  saveSensorData();
//	        }, 1000);
	    	
	    } else {
	        //local has been unchecked, stop saving
	    	console.log("stopping local saving of accel");
	    	//clearInterval(saveIntervalId);
	    	saveAccel=false;
	    }
	};
	
	
	   var orienIntervalId;
	   document.getElementById("orien_check").onchange=function(event) {
		    var checkbox = event.target;
		    if (checkbox.checked) {
		        //local has been checked, initialize file and write data
		    	console.log("initializing local file for orien data...");
		    	initializeOrientation();
		    	saveOrien=true;
		    	orienData=[];
//		    	orienIntervalId=setInterval(function(){ 
//		    	  saveOrientation();
//		        }, 1000);
		    	
		    } else {
		        //local has been unchecked, stop saving
		    	console.log("stopping local saving of accel");
		    	//clearInterval(orienIntervalId);
		    	saveOrien=false;
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
	if(accelData.length>1){
	    document.getElementById("xaccel").innerHTML = "X: "+ accelData[1].x;
	    document.getElementById("yaccel").innerHTML = "Y: "+ accelData[1].y;
	    document.getElementById("zaccel").innerHTML = "Z: "+ accelData[1].z;
	    //update power
		tizen.systeminfo.getPropertyValue("BATTERY", function(battery){
			currPower=battery.level;
		});
		//open file and write data
		tizen.filesystem.resolve(accelDataPath,function(file){
			file.openStream("a", function(fs){
				//write data as csv
				accelData.forEach(function(element){
					fs.write(element.time+","+currPower+","+element.x+","+element.y+","+element.z+"\n");
				});
				fs.close();
			    accelData=[];
			}, null, "UTF-8");
		});
	}

}


saveOrientation = function(){
	if(orienData.length>1){
	    document.getElementById("alpha").innerHTML = "Alpa: "+ orienData[1].alpha;
	    document.getElementById("beta").innerHTML = "Beta: "+ orienData[1].beta;
	    document.getElementById("gamma").innerHTML = "Gamma: "+ orienData[1].gamma;
	    //update power
		tizen.systeminfo.getPropertyValue("BATTERY", function(battery){
			currPower=battery.level;
		});
		//open file and write data
		tizen.filesystem.resolve(orienDataPath,function(file){
			file.openStream("a", function(fs){
				//write data as csv
				orienData.forEach(function(element){
					fs.write(element.time+","+currPower+","+element.alpha+","+element.beta+","+element.gamma+"\n");
				});
				fs.close();
			    orienData=[];
			}, null, "UTF-8");
		});
	}

}

var hrSem = false;
saveHrData = function(){
	//open file and write data
	if(!hrSem){
		hrSem=true;
		window.webapis.motion.start("HRM", function(hrm) {
			tizen.filesystem.resolve(hrDataPath,function(file){
				file.openStream("a", function(fs){
					if(hrm.heartRate>0){
						document.getElementById("hr").innerHTML ="HR: "+ hrm.heartRate;
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
				fs.write("time,power,x,y,z\n");
				fs.close();
				}, null, "UTF-8");
	  });
}

initializeOrientation = function(){
	  //create new accelData-File with timestamp in /opt/usr/media/Documents
	  var orienDataName = "orienData_"+Date.now()+".csv";
	  orienDataPath = "documents/"+orienDataName;
	  console.log("using file: "+orienDataPath);
	  tizen.filesystem.resolve("documents", function(path){
		  var file = path.createFile(orienDataName);
		  file.openStream("w", function(fs){
				//write header
				fs.write("time,power,alpha,beta,gamma\n");
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


