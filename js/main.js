var accelDataPath;
var ax;
var ay;
var az;

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

    //read acceleration values when motion event occurs
    //TODO get average acceleration, set interval of this event
    window.addEventListener('devicemotion', function(e) {
    		      ax = e.acceleration.x;
    		      ay = e.acceleration.y;
    		      az = e.acceleration.z;
    		    });
       
   //look for checked checkboxes and initialize accordingly
   var saveIntervalId;
   document.getElementById("local_check").onchange=function(event) {
	    var checkbox = event.target;
	    if (checkbox.checked) {
	        //local has been checked, initialize file and write data
	    	console.log("initializing local file...");
	    	initializeLocal();
	    	saveIntervalId=setInterval(function(){ 
	    	  saveSensorData();
	        }, 1000);
	    	
	    } else {
	        //local has been unchecked, stop saving
	    	console.log("stopping local saving");
	    	clearInterval(saveIntervalId);
	    }
	};
	    
	var sendIntervalId;
	document.getElementById("bt_check").onchange=function(event){
		var checkbox = event.target;
		if(checkbox.checked){
			//bt has been checked, initialize bt and send
			console.log("initializing bt connection...");
			var socket = initializeBT();
			sendIntervalId = setInterval(function(){
				sendSensorData(socket);	
			}, 1000);
			
		}else{
			//bt has been unchecked, stop sending
			console.log("stopping to send data...");
			clearInterval(sendIntervalId);
		}
	};
	
	var showIntervalId;
	document.getElementById("show_check").onchange=function(event){
		var checkbox = event.target;
		if(checkbox.checked){
			//show has been checked
			console.log("showing data...");
			showIntervalId = setInterval(function(){
				showSensorData();
			}, 1000);
			
		}else{
			//show has been unchecked
			console.log("stopping to show data...");
			clearInterval(showIntervalId);
		}
	}
    
};//end onload

//function that shows sensor data on screen
showSensorData = function(){
    document.getElementById("xaccel").innerHTML =  'X : ' +  ax;
    document.getElementById("yaccel").innerHTML = 'Y : ' + ay;
    document.getElementById("zaccel").innerHTML = 'Z : ' + az;
}


//function that saves values
saveSensorData = function(){
	//open file and write data
	tizen.filesystem.resolve(accelDataPath,function(file){
		file.openStream("a", function(fs){
			//write data as csv
			fs.write(Date.now()+","+ax+","+ay+","+az+"\n");
			fs.close();
			}, null, "UTF-8");
	});
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


//connect to bt-server
initializeBT = function(){
	var adapter = tizen.bluetooth.getDefaultAdapter();
	//find device
	adapter.discoverDevices(discoverDevicesSuccessCallback, null);
	var discoverDevicesSuccessCallback =
	{
	   /* When a device is found */
	   ondevicefound: function(device)
	   {
	      console.log("Found device - name: " + device.name);
	      //TODO save device and address of device
	   }
	}
	
	//bond with device (TODO insert adress of device (or try adress of laptop: C0:F8:DA:F5:C9:1F hcitool dev)
	adapter.createBonding("35:F4:59:D1:7A:03", onBondingSuccessCallback, onErrorCallback);
	
	function onBondingSuccessCallback(device)
	{
	   console.log("A bonding is created - name: " + device.name);
	}

	function onErrorCallback(e)
	{
	   console.log("Cannot create a bonding, reason: " + e.message);
	}
	
	//finally connect to the service TODO use right uuid (hard-coded or from device)
	var socket;
	device.connectToServiceByUUID(serviceUUID, function(sock)
			   {
			      console.log("socket connected");
			      socket = sock;
			   },
			   function(error)
			   {
			      console.log("Error while connecting: " + error.message);
			   }
			);
	
	//var somemsg = "test"; //was array in example
	//socket.writeData(somemsg);
	return socket;
}


sendSensorData = function(socket){
	socket.writeData(Date.now()+","+ax+","+ay+","+az+"\n");
}
