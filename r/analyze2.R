setwd("/home/stefan/workspace-tizen2/SleepTracking/r")


accel=read.csv("data/02-01/accelData_1454278149781.csv")
orient=read.csv(("data/02-01/orienData_1454278150246.csv"))

#features-fkt
feature=function(wsize,data,ffunct,overlap){
  start=1-(wsize-overlap)
  numwindows=length(data)/(wsize-overlap)
  result=1:numwindows
  
  for(i in 1:numwindows){
    start=start+wsize-overlap
    end=start+wsize-1
    
    windowed=data[start:end]
    result[i]=ffunct(windowed)
  }
  return(result)
}
#TODO: accel und orient-features muessen genau zueinander passen, das geht mit dieser komischen sampling-frequenz schlecht.
#besser: doch beides sekundenweise aufzeichnen, jeweils gleichzeitig speichern (mit jew. gleichem timestamp, vll sogar in einer datei)
#orient nicht gut, wenn minutenweise avg: hohe frequenzen gehen verloren (besser: mass fuer starke schwankungen?)

#das hier geht nicht richtig, da jeweilige timeslots nicht genau zueinander passen
accel$time=(accel$time-accel$time[1])/1000
accelmag=sqrt(accel$x^2+accel$y^2+accel$z^2)
accelavg=feature(60*25,accelmag,mean,0)#25 Hz, minutenweise mittelwert bilden

orient$time=(orient$time-orient$time[1])/1000
orientavga=feature(17*60,orient$alpha,mean,0)#orient mit 16.6 Hz aufgenommen
