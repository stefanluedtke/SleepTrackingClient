#notizen hierzu:
#1. andere sinnvolle featueres/kombinationen?
#2. liefert hohe sensit., geringe spez.
#3. regression und lda (fast) gleich
#4. qda viel besser (auf trainingsdaten)

library(seewave)
setwd("/home/stefan/workspace-tizen2/r")

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

s1=read.csv("data/training1/sleep1.csv")
s1$time=(s1$time-s1$time[1])/1000

w1=read.csv("data/training1/awake1.csv")
w1$time=(w1$time-w1$time[1])/1000


#-------------------------
#alles mit mittelwerten

#mittelwerte berechnen
s1mag=sqrt(s1$x^2+s1$y^2+s1$z^2)
s1a=feature(25*60,s1mag,mean,0)

w1mag=sqrt(w1$x^2+w1$y^2+w1$z^2)
w1a=feature(25*60,w1mag,mean,0)


#features berechnen
BEFORE=10
AFTER=5
s1f=matrix(nrow=length(s1a),ncol=(BEFORE+AFTER+1))
for(i in (BEFORE+1):(length(s1a)-(AFTER+1))){
  s1f[i, ]=s1a[(i-BEFORE):(i+AFTER)]
}

w1f=matrix(nrow=length(w1a),ncol=(BEFORE+AFTER+1))
for(i in (BEFORE+1):(length(w1a)-(AFTER+1))){
  w1f[i, ]=w1a[(i-BEFORE):(i+AFTER)]
}

features=rbind(s1f,w1f)

#labels angeben
y1=1:length(s1a)
y1[1:length(s1a)]=0
y2=1:length(w1a)
y2[1:length(w1a)]=1
y=c(y1,y2)


#model bauen (regression)
model=lm(y~.,data=data.frame(features))
yfit=predict(model,data.frame(features))

p=yfit
p[yfit>=0.5]=1
p[yfit<0.5]=0
plot(c(s1a,w1a),type="l")
lines(p,col="red")

#Bewertung:
#accuracy
length(y[y==p&!(is.na(p))])/length(y&!(is.na(p)))
#sensitivity
length(y[y==0&p==0&!(is.na(p))])/length(y[y==0&!(is.na(p))])
#specifity
length(y[y==1&p==1&!(is.na(p))])/length(y[y==1&!(is.na(p))])

#model bauen (mit lda)
require(MASS)
model=lda(y~.,data=data.frame(features))
yfit=predict(model,data.frame(features))

p=as.numeric(levels(yfit$class))[yfit$class]
plot(c(s1a,w1a),type="l")
lines(p,col="red")

#Bewertung:
#accuracy
length(y[y==p&!(is.na(p))])/length(y&!(is.na(p)))
#sensitivity
length(y[y==0&p==0&!(is.na(p))])/length(y[y==0&!(is.na(p))])
#specifity
length(y[y==1&p==1&!(is.na(p))])/length(y[y==1&!(is.na(p))])


#--------------------------
#alles mit zero crossing
s1lp=s1$x
s1lp[abs(s1lp)<0.1]=0
s1z=zcr(s1lp,25,25*60,plot=FALSE)
s1z=s1z[,2]

w1lp=w1$x
w1lp[abs(w1lp)<0.1]=0
w1z=zcr(w1lp,25,25*60,plot=FALSE)
w1z=w1z[,2]


#features berechnen
BEFORE=10
AFTER=5
s1f=matrix(nrow=length(s1z),ncol=(BEFORE+AFTER+1))
for(i in (BEFORE+1):(length(s1z)-(AFTER+1))){
  s1f[i, ]=s1z[(i-BEFORE):(i+AFTER)]
}

w1f=matrix(nrow=length(w1z),ncol=(BEFORE+AFTER+1))
for(i in (BEFORE+1):(length(w1z)-(AFTER+1))){
  w1f[i, ]=w1z[(i-BEFORE):(i+AFTER)]
}

features=rbind(s1f,w1f)

#labels angeben
y1=1:length(s1z)
y1[1:length(s1z)]=0
y2=1:length(w1z)
y2[1:length(w1z)]=1
y=c(y1,y2)

#model bauen (regression)
model=lm(y~.,data=data.frame(features))
yfit=predict(model,data.frame(features))

p=yfit
p[yfit>=0.5]=1
p[yfit<0.5]=0
plot(c(s1z,w1z),type="l")
lines(p,col="red")

#Bewertung:
#accuracy
length(y[y==p&!(is.na(p))])/length(y&!(is.na(p)))
#sensitivity
length(y[y==0&p==0&!(is.na(p))])/length(y[y==0&!(is.na(p))])
#specifity
length(y[y==1&p==1&!(is.na(p))])/length(y[y==1&!(is.na(p))])

#model bauen (mit lda)
require(MASS)

model=lda(y~.,data=data.frame(features))
yfit=predict(model,data.frame(features))

p=as.numeric(levels(yfit$class))[yfit$class]
plot(c(s1z,w1z),type="l")
lines(p,col="red")


#model bauen (mit svm)
require(e1071)
ysvm=y[complete.cases(features)]
featuressvm=features[complete.cases(features),]
ysvm=factor(ysvm)

model=svm(ysvm~.,data=data.frame(featuressvm))
yfit=predict(model,data.frame(featuressvm))

p=as.numeric(yfit)-1
plot(c(s1z,w1z)[complete.cases(features)],type="l")
lines(p,col="red")

#Bewertung:
#accuracy
length(y[y==p&!(is.na(p))])/length(y&!(is.na(p)))
#sensitivity
length(y[y==0&p==0&!(is.na(p))])/length(y[y==0&!(is.na(p))])
#specifity
length(y[y==1&p==1&!(is.na(p))])/length(y[y==1&!(is.na(p))])


#parameter: anzahl der features
#orientation-daten benutzen

#testdaten:
test=read.csv("data/training1/test1.csv")

testlp=test$x
testlp[abs(testlp)<0.1]=0
testz=zcr(testlp,25,25*60,plot=FALSE)
testz=testz[,2]

#testmag=sqrt(test$x^2+test$y^2+test$z^2)
#testz=feature(25*60,testmag,mean,0)


#features berechnen
BEFORE=10
AFTER=5
testf=matrix(nrow=length(testz),ncol=(BEFORE+AFTER+1))
for(i in (BEFORE+1):(length(testz)-(AFTER+1))){
  testf[i, ]=testz[(i-BEFORE):(i+AFTER)]
}


#klassifikation (lda)
yfit=predict(model,data.frame(testf))
p=as.numeric(levels(yfit$class))[yfit$class]

plot(testz,type="l")
lines(p,col="red")

#klassifikation (svm)
testfsvm=testf[complete.cases(testf),]
yfit=predict(model,data.frame(testfsvm))
p=as.numeric(yfit)-1

plot(testz[complete.cases(testf)],type="l")
lines(p,col="red")

