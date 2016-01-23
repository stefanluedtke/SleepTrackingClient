setwd("/home/stefan/workspace-tizen2/SleepTracking/r")

#accel1=read.csv("data/01-21/accelData_1453394182570.csv")
#accel2=read.csv("data/01-21/accelData_1453403870411.csv")
#accel3=read.csv("data/01-21/accelData_1453414432402.csv")

#accel=rbind(accel1,accel2,accel3)

accel=read.csv("data/01-22/accelData_1453455351608.csv")

accel$time=(accel$time-accel$time[1])/1000

plot(accel$time,accel$y,type="l")

#Batterie-Verbrauch: ca. 50% fr 3 Stunden

#muessten vor fft alle daten auf gleichen abstand gebracht werden (oder wie geht das)
#plot(Mod(fft(accel$x)),type="l")