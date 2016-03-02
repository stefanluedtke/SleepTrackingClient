setwd("/home/stefan/workspace-tizen2/SleepTracking/r")

#HR-Daten: (hab nur ruhig dagesessen)
h=read.csv("data/HR/ruhepuls.csv")
h$time=(h$time-h$time[1])/1000
plot(h$time,h$hr,type="l")

a=read.csv("data/01-28/accelData_1454000916568.csv") #diese daten sind mit hoechstmoeglicher frequenz gesampled
diff=sapply(1:579,function(i){a$time[i+1]-a$time[i]})
#plot(diff)

#schlafdaten sehen so aus:
#(auch interessant: 02-01: orientationData)
a=read.csv("data/02-01/accelData_1454278149781.csv")
o=read.csv(("data/02-01/orienData_1454278150246.csv"))
plot(o$time,o$alpha,type="l")
lines(a$time,a$x,col="green")
