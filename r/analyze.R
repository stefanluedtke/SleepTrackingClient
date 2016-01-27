setwd("/home/stefan/workspace-tizen2/SleepTracking/r")


#TODO bei datenaufnahme immer gleich avg berechnen (mitzaehlen, wie oft summiert, und dadurch teilen, bevor geschrieben)

#daten lesen und minutenweise Mittelwert bilden
accel=read.csv("data/01-25/accelData_1453674290848.csv")
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


#Batterie-Verbrauch: ca. 50% fuer 3 Stunden bei 20Hz
#ca. 90% fuer 12 stunden bei 1Hz (summiert)

#plot(Mod(fft(accel$x)),type="l")

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