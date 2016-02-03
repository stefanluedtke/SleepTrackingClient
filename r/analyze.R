setwd("/home/stefan/workspace-tizen2/SleepTracking/r")

#1. welche sensoren gehen, welche nicht
#2. samplingfreq 25hz, immer speichern: akku nach 6h leer
# nur 1x pro sekunde speichern, mittelwert: haelt 13 stunden
# problem bei 25 Hz und nur 1x pro sekunde speichern: werden nicht gleichfoermig gesampled, siehe:
# (vll sind ausreisser immer dann, wenn ich daten speicher?)
#weiteres problem: Aufzeichnung bricht nach ca 5 stunden ab, wenn beides aufgezeichnet. wenn nur o, dann nicht
a=read.csv("data/01-28/accelData_1454000916568.csv") #diese daten sind mit hoechstmoeglicher frequenz gesampled
diff=sapply(1:579,function(i){a$time[i+1]-a$time[i]})
#plot(diff)

#4. schlafdaten sehen so aus:
#(auch interessant: 02-01: orientationData)
#a=read.csv("data/02-01/accelData_1454278149781.csv")
#o=read.csv(("data/02-01/orienData_1454278150246.csv"))
#plot(o$time,o$alpha,type="l")
#lines(a$time,a$x,col="green")

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

#daten lesen und minutenweise Mittelwert bilden TODO minutenweise, nicht immer 60 werte aufaddieren
accel=read.csv("data/01-25/accelData_1453674290848.csv") #diese daten wurden sekundenweise summiert (nicht so gut)
accel$time=(accel$time-accel$time[1])/1000
accelmag=sqrt(accel$x^2+accel$y^2+accel$z^2)
accelavg=feature(60,accelmag,mean,0)

plot(accelavg,type="l")



#features berechnen
features=matrix(nrow=length(accelavg),ncol=7)
for(i in 5:(length(accelavg)-3)){
  features[i, ]=accelavg[(i-4):(i+2)]
}

#label bauen
y=1:length(accelavg)
y[1:length(accelavg)]=0
y[30:640]=1

#model bauen
model=lm(y~X1+X2+X3+X4+X5+X6+X7,data=data.frame(features))
yfit=predict(model,data.frame(features))
lines(yfit*60,col="red")



#plot(Mod(fft(accel$x)),type="l")

