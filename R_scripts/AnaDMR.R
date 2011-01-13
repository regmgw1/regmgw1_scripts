\author{Andrew Teschendorff}

myEnrichmentFile<-"/my/path/to/enrichment/.txt"
dmrcount.df <- read.table(myEnrichmentFile,row.names=1,head=FALSE,sep="\t")
dmrcount.lm <- list(t(dmrcount.df))
### AnaDMR.R
library(epitools);
nDMR.v <- vector();
nR.v <- vector();
for(c in 1:length(dmrcount.lm)){
  nDMR.v[c] <- sum(dmrcount.lm[[c]][1,])
 nR.v[c] <- sum(dmrcount.lm[[c]][2,])
}

fDMR.v <- nDMR.v/nR.v;

dmrPV.lm <- list(); odds.lm <- list();
for(c in 1:length(dmrcount.lm)){

 dmrPV.lm[[c]] <- matrix(nrow=8,ncol=ncol(dmrcount.lm[[c]]));
 odds.lm[[c]] <- matrix(nrow=4,ncol=ncol(dmrcount.lm[[c]]));

 dmrPV.lm[[c]][1,] <- dmrcount.lm[[c]][1,]; ## observed
 dmrPV.lm[[c]][2,] <- dmrcount.lm[[c]][2,]*fDMR.v[c]; ### expected

 dmrPV.lm[[c]][3,] <- dmrcount.lm[[c]][1,]/dmrcount.lm[[c]][2,];## obs.freq
 dmrPV.lm[[c]][4,] <- rep(fDMR.v[c],ncol(dmrcount.lm[[c]]));

 dmrPV.lm[[c]][5,] <- dmrcount.lm[[c]][1,]/sum(dmrcount.lm[[c]][1,]);
 dmrPV.lm[[c]][6,] <- dmrcount.lm[[c]][2,]/sum(dmrcount.lm[[c]][2,]);
 
 for (f in 1:ncol(dmrcount.lm[[c]])){

   dmrPV.lm[[c]][7,f] <- pbinom(dmrcount.lm[[c]][1,f],dmrcount.lm[[c]][2,f],prob=fDMR.v[c],log.p=TRUE,lower.tail=FALSE);
   dmrPV.lm[[c]][8,f] <- pbinom(dmrcount.lm[[c]][1,f],dmrcount.lm[[c]][2,f],prob=fDMR.v[c],log.p=FALSE,lower.tail=FALSE);

   tmp.m <- matrix(nrow=2,ncol=2);
   tmp.m[1,1] <- dmrcount.lm[[c]][1,f];
   tmp.m[1,2] <- sum(dmrcount.lm[[c]][1,])-tmp.m[1,1];
   tmp.m[2,1] <- dmrcount.lm[[c]][2,f]-tmp.m[1,1];
   tmp.m[2,2] <- sum(dmrcount.lm[[c]][2,])-tmp.m[1,1]-tmp.m[2,1]-tmp.m[1,2];

   tmpOR.o <-  oddsratio(tmp.m,method="fisher");
   odds.lm[[c]][1:3,f] <- tmpOR.o$measure[2,];
   odds.lm[[c]][4,f] <- tmpOR.o$p.value[2,2];

 }

 print(c);

 rownames(dmrPV.lm[[c]]) <- c("ObsN","ExpN","p(DMR|f)","E[p(DMR|f)]","p(f|DMR)","E[p(f|DMR)]","log(Pval)","Pval");
 colnames(dmrPV.lm[[c]]) <- colnames(dmrcount.lm[[c]]);
 rownames(odds.lm[[c]]) <- c("OR","Low95CI","High95CI","Pval");
 colnames(odds.lm[[c]]) <- colnames(dmrcount.lm[[c]]);

}
names(dmrPV.lm) <- names(dmrcount.lm);
names(odds.lm) <- names(dmrcount.lm);

for(c in 1:length(dmrPV.lm)){

  out.m <- cbind(rownames(dmrPV.lm[[c]]),dmrPV.lm[[c]]);
  colnames(out.m) <- c("Variable",colnames(dmrPV.lm[[c]]));
  write.table(out.m,file=paste("cpgBinomSummary-",names(dmrPV.lm)[c],".txt",sep=""),sep="\t",quote=FALSE,row.names=FALSE);

  out.m <- cbind(rownames(odds.lm[[c]]),odds.lm[[c]]);
  colnames(out.m) <- c("Variable",colnames(odds.lm[[c]]));
  write.table(out.m,file=paste("cpgOddsSummary-",names(odds.lm)[c],".txt",sep=""),sep="\t",quote=FALSE,row.names=FALSE);
}
xlim.lv <- list();

for(c in seq(1,6,2)){ xlim.lv[[c]] <- c(0,30);}
for(c in seq(2,6,2)){ xlim.lv[[c]] <- c(0,30);}
pdf("cpg_enrichment_plot.pdf")
par(cex.axis=0.9,mar=c(3,10,3,1))
plot.v <- (odds.lm[[1]][1,]-1)/(odds.lm[[1]][1,]-odds.lm[[1]][2,]);
plot.v[which(plot.v<0)] <- 0;
color.v <- rep("grey",ncol(dmrPV.lm[[1]]));
color.v[intersect(which(odds.lm[[1]][4,] < 0.001),which(odds.lm[[1]][1,]>1))] <- "red";
barplot(plot.v,beside=TRUE,xlim=xlim.lv[[1]],main=names(dmrPV.lm)[1],horiz=TRUE,axes=FALSE,las=2,names.arg=colnames(dmrPV.lm[[1]]),col=color.v);
axis(1);
dev.off()
