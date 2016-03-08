setwd("/home/stefan/workspace-tizen2/SleepTracking/r")

#dat=read.csv("data/albert/scopetraces.csv",nrows=100000)
datraw=read.csv("data/albert/20160204085250_20160205020357_samples_export_derived.csv",colClasses = c(NA,"NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL",NA,NA,NA,NA,NA,NA,"NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"))

#HIER
#unregelmaessigkeit der ticks: (was bedeuten ticks ueberhaupt genau?)
#plot(dat$X.fulltest_20160204.Tick.[1000:1100],type="l")

#kann es sein, dass gyro und accel vertauscht sind? (accel sieht aus wie bei mir gyro und umgekehrt)
plot(gyrox[seq(1,14000000,100)],type="l")
#plot(accelx[seq(10000000,14000000,1)],type="l")

#wie mit na-werten in daten umgehen?? (habe die jetzt in counts nicht mitgezaehlt)
#besser soviele in einen count aufsummieren, bis neue sekunde in date anfaengt

#in schlaf-phase ist noch viel mehr aktivitaet als bei meinen daten, dadurch schlechtere klassifikation

#gyrox-daten sehen abgeschnitten aus oben und unten -> ?

preproc=function(row){
  accelx=(levels(row))[row]
  accelx=gsub(",", ".", accelx)
  accelx=as.numeric(accelx)
}


accelx=preproc(datraw$ALGO_DATA_ACCELEROMETER_WRIST_X)
accely=preproc(datraw$ALGO_DATA_ACCELEROMETER_WRIST_Y)
accelz=preproc(datraw$ALGO_DATA_ACCELEROMETER_WRIST_Z)
gyrox=preproc(datraw$ALGO_DATA_GYRO_WRIST_X)
gyroy=preproc(datraw$ALGO_DATA_GYRO_WRIST_Y)
gyroz=preproc(datraw$ALGO_DATA_GYRO_WRIST_Z)
#tempskin=preproc(datraw$ALGO_DATA_TEMPERATURE_WRIST_SKIN)
#tempref=preproc(datraw$ALGO_DATA_TEMPERATURE_WRIST_REFERENCE)
#pressure=preproc(datraw$ALGO_DATA_PRESSURE_SENSOR_WRIST)

#cleandata=data.frame(accelx,accely,accelz)


#-----------------------
#modell bauen (vll als ersten schritt 1 zu 1 den nagazaki-alg nachbauen? (da dort auch das mit dem threshold drinsteht))


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

#funktion, die activity-counts berechnet. funktioniert mit 5 am besten aus Nakazaki14.
generateCount=function(dat){
  sum(dat>50&!is.na(dat))/(100*60)
}

#funktion, die features berechnet
getFeatureMatrix = function(s1a,BEFORE,AFTER){
  s1f=matrix(nrow=length(s1a),ncol=(BEFORE+AFTER+1))
  for(i in (BEFORE+1):(length(s1a)-(AFTER+1))){
    s1f[i, ]=s1a[(i-BEFORE):(i+AFTER)]
  }
  return(s1f)
}



#berechne features
#todo: wie mit nan-werten umgehen??
accelmag=sqrt(gyrox^2+gyroy^2+gyroz^2)

#nur teil der daten-------------------------------------------
accelmag2=accelmag[10000000:length(accelmag)]

counts=feature(100*60,accelmag2,generateCount,0) #(da 100 Hz), aber: timestamp spricht eher fuer 185 Hz oder so? na-werte werden nicht gezaehlt
#besser: immer so viele nehmen, bis neue sekunde in date anfaengt
plot(counts,type="l")

features=getFeatureMatrix(counts,10,5)


#labels angeben
y=1:length(counts)
y[1:350]=1
y[351:length(counts)]=0

model=lm(y~.,data=data.frame(features))

#predict auf ganzen daten
countsg=feature(100*60,accelmag,generateCount,0)
featuresg=features=getFeatureMatrix(countsg,10,5)
yfit=predict(model,data.frame(featuresg))

p=yfit
p[yfit>=0.5]=1
p[yfit<0.5]=0
plot(countsg,type="l")
lines(p,col="red")

yg=1:length(p)
yg[1:2000]=1
yg[2001:length(p)]=0

#Bewertung:
#accuracy
length(yg[yg==p&!(is.na(p))])/length(yg&!(is.na(p)))
#sensitivity
length(yg[yg==0&p==0&!(is.na(p))])/length(yg[yg==0&!(is.na(p))])
#specifity
length(yg[yg==1&p==1&!(is.na(p))])/length(yg[yg==1&!(is.na(p))])
