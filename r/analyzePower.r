setwd("/home/stefan/workspace-tizen2/SleepTracking/r")

#a1: 1x pro sekunde, nur accel
a1=read.csv("data/power_tests/accelData_1454686725718.csv",comment.char = "#", colClasses = c(NA,NA,"NULL","NULL","NULL"))
a1$time=(a1$time-a1$time[1])/1000

lma1=lm(power~time,a1)
preda1=predict.lm(lma1,newdata=data.frame(time=1:45000))

plot(1:45000,preda1,col="red",type="l")
lines(a1$time,a1$power)

which.min(abs(preda1))

#a2: 1x pro minute, nur accel
a2=read.csv("data/power_tests/4/accelData_1454879284512.csv",comment.char = "#", colClasses = c(NA,NA,"NULL","NULL","NULL"))
a2$time=(a2$time-a2$time[1])/1000
plot(a2$time,a2$power,type="l")


#a3: 1x pro sekunde, accel und orien
a3=read.csv("data/power_tests/3/accelData_1454849523847.csv",comment.char = "#", colClasses = c(NA,NA,"NULL","NULL","NULL"))
a3$time=(a3$time-a3$time[1])/1000
plot(a1$time,a1$power,type="l")
lines(a3$time,a3$power,col="red")
