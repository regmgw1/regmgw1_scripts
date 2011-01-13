\author{Andrew Teschendorff & Gareth Wilson}


### GenFig.R


### figure 1
xlim.lv <- list();

for(c in seq(1,6,2)){ xlim.lv[[c]] <- c(0,2);}
for(c in seq(2,6,2)){ xlim.lv[[c]] <- c(0,3);}

par(mfcol=c(2,4));
par(mar=c(3,6,3,0));
for(c in 1:2){
 plot(x=rep(1,ncol(dmrPV.lm[[1]])),y=1:ncol(dmrPV.lm[[1]]),col="white",axes=FALSE,xlab="",ylab="");
 #axis(2,at=1:ncol(dmrPV.lm[[1]]),labels=colnames(dmrPV.lm[[1]]),las=2);
}
par(mar=c(3,3,3,1));
for(c in 1:2){
 plot.v <- dmrPV.lm[[c]][5,]/dmrPV.lm[[c]][6,];
 color.v <- rep("grey",ncol(dmrPV.lm[[c]]));
 color.v[which(dmrPV.lm[[c]][8,] < 0.001)] <- "red";
 barplot(plot.v,beside=TRUE,xlim=xlim.lv[[c]],main=names(dmrPV.lm)[c],horiz=TRUE,axes=FALSE,las=2,names.arg=colnames(dmrPV.lm[[c]]),col=color.v);
 #plot(x=plot.v,y=1:length(plot.v),type="h",lwd=3,main=names(dmrPV.lm)[c],axes=FALSE)
 axis(1); #axis(2,at=1:length(plot.v),labels=colnames(dmrPV.lm[[c]]),las=2,tick=FALSE);
# points(x=dmrPV.lm[[c]][4,],y=1:length(plot.v),col="green",pch=23,cex=0.25);
}
for(c in 3:length(dmrPV.lm)){
 plot.v <- dmrPV.lm[[c]][5,]/dmrPV.lm[[c]][6,];
 color.v <- rep("grey",ncol(dmrPV.lm[[c]]));
 color.v[which(dmrPV.lm[[c]][8,] < 0.001)] <- "red";
 barplot(plot.v,beside=TRUE,xlim=xlim.lv[[c]],main=names(dmrPV.lm)[c],horiz=TRUE,axes=FALSE,names.arg=FALSE,col=color.v);
 axis(1); 
# points(x=dmrPV.lm[[c]][4,],y=1:length(plot.v),col="green",pch=23);
# abline(v=dmrPV.lm[[c]][4,1],col="green",lwd=2,lty=2);
}


### figure 2
### odds
xlim.lv <- list();

for(c in seq(1,6,2)){ xlim.lv[[c]] <- c(0,2);}
for(c in seq(2,6,2)){ xlim.lv[[c]] <- c(0,3);}

par(mfcol=c(2,4));
par(mar=c(3,6,3,0));
for(c in 1:2){
 plot(x=rep(1,ncol(dmrPV.lm[[1]])),y=1:ncol(dmrPV.lm[[1]]),col="white",axes=FALSE,xlab="",ylab="");
 #axis(2,at=1:ncol(dmrPV.lm[[1]]),labels=colnames(dmrPV.lm[[1]]),las=2);
}
par(mar=c(3,3,3,1));
for(c in 1:2){
 plot.v <- odds.lm[[c]][1,];
 color.v <- rep("grey",ncol(dmrPV.lm[[c]]));
 color.v[intersect(which(odds.lm[[c]][4,] < 0.001),which(odds.lm[[c]][1,]>1))] <- "red";
 barplot(plot.v,beside=TRUE,xlim=xlim.lv[[c]],main=names(dmrPV.lm)[c],horiz=TRUE,axes=FALSE,las=2,names.arg=colnames(dmrPV.lm[[c]]),col=color.v);
 #plot(x=plot.v,y=1:length(plot.v),type="h",lwd=3,main=names(dmrPV.lm)[c],axes=FALSE)
 axis(1); #axis(2,at=1:length(plot.v),labels=colnames(dmrPV.lm[[c]]),las=2,tick=FALSE);
# points(x=dmrPV.lm[[c]][4,],y=1:length(plot.v),col="green",pch=23,cex=0.25);
}
for(c in 3:length(dmrPV.lm)){
 plot.v <- odds.lm[[c]][1,];
 color.v <- rep("grey",ncol(dmrPV.lm[[c]]));
 color.v[intersect(which(odds.lm[[c]][4,] < 0.001),which(odds.lm[[c]][1,]>1))] <- "red";
 barplot(plot.v,beside=TRUE,xlim=xlim.lv[[c]],main=names(dmrPV.lm)[c],horiz=TRUE,axes=FALSE,names.arg=FALSE,col=color.v);
 axis(1); 
# points(x=dmrPV.lm[[c]][4,],y=1:length(plot.v),col="green",pch=23);
# abline(v=dmrPV.lm[[c]][4,1],col="green",lwd=2,lty=2);
}


### figure 3
### deviation from null odds
xlim.lv <- list();

for(c in seq(1,6,2)){ xlim.lv[[c]] <- c(0,30);}
for(c in seq(2,6,2)){ xlim.lv[[c]] <- c(0,30);}

par(mfcol=c(2,4));
par(mar=c(3,6,3,0));
for(c in 1:2){
 plot(x=rep(1,ncol(dmrPV.lm[[1]])),y=1:ncol(dmrPV.lm[[1]]),col="white",axes=FALSE,xlab="",ylab="");
 #axis(2,at=1:ncol(dmrPV.lm[[1]]),labels=colnames(dmrPV.lm[[1]]),las=2);
}
par(mar=c(3,3,3,1));
for(c in 1:1){
 plot.v <- (odds.lm[[c]][1,]-1)/(odds.lm[[c]][1,]-odds.lm[[c]][2,]);
 plot.v[which(plot.v<0)] <- 0;
 color.v <- rep("grey",ncol(dmrPV.lm[[c]]));
 color.v[intersect(which(odds.lm[[c]][4,] < 0.001),which(odds.lm[[c]][1,]>1))] <- "red";
 barplot(plot.v,beside=TRUE,xlim=xlim.lv[[c]],main=names(dmrPV.lm)[c],horiz=TRUE,axes=FALSE,las=2,names.arg=colnames(dmrPV.lm[[c]]),col=color.v);
 #plot(x=plot.v,y=1:length(plot.v),type="h",lwd=3,main=names(dmrPV.lm)[c],axes=FALSE)
 axis(1); #axis(2,at=1:length(plot.v),labels=colnames(dmrPV.lm[[c]]),las=2,tick=FALSE);
# points(x=dmrPV.lm[[c]][4,],y=1:length(plot.v),col="green",pch=23,cex=0.25);
}
for(c in 3:length(dmrPV.lm)){
 plot.v <- (odds.lm[[c]][1,]-1)/(odds.lm[[c]][1,]-odds.lm[[c]][2,]);
 plot.v[which(plot.v<0)] <- 0;
 color.v <- rep("grey",ncol(dmrPV.lm[[c]]));
 color.v[intersect(which(odds.lm[[c]][4,] < 0.001),which(odds.lm[[c]][1,]>1))] <- "red";
 barplot(plot.v,beside=TRUE,xlim=xlim.lv[[c]],main=names(dmrPV.lm)[c],horiz=TRUE,axes=FALSE,names.arg=FALSE,col=color.v);
 axis(1); 
# points(x=dmrPV.lm[[c]][4,],y=1:length(plot.v),col="green",pch=23);
# abline(v=dmrPV.lm[[c]][4,1],col="green",lwd=2,lty=2);
}
