\author{Gareth Wilson}

outDir <- "path/to/output/dir"
############
# If have seperate file for each chrom
###########
chr.v<-1:19
diff.v <- vector()
mean.v <- vector()
pdf(paste(outDir,"sample12_frag_dist.pdf",sep=""))
layout(matrix(1:20,4,5,byrow=T))
for (i in 1:length(chr.v)){
  tmp<-read.table(paste(outDir,"sample12_neuTDGmm_pippy_chr",i,"_v2.gff",sep=""),sep="\t",head=F)
  tmpDiff.v <- tmp$V5-tmp$V4
  diff.v <- append(diff.v,tmpDiff.v)
  mean.v[i] <- mean(tmpDiff.v)
  hist(tmpDiff.v,col="green",main=paste("chr",i,sep=""),xlab=round(mean(tmpDiff.v),2),font.main=1)
  rm(tmpDiff.v,tmp)
}
mean <- mean(diff.v)
hist(diff.v,col="red",main="Sample 12",xlab=round(mean,1))
dev.off()

###########
# if single whole genome file
##########
samples.v <- 7:12
pdf(paste(outDir,"normalised_sample_frag_dist.pdf",sep=""))
layout(matrix(1:6,2,3,byrow=T))
for (i in samples.v[1]:samples.v[length(samples.v)]){
  tmp<-read.table(paste(outDir,"nsc_normalised_sample",i,"_TDG_chr.bed",sep=""),sep="\t",head=F)
  tmpDiff.v <- tmp$V2-tmp$V3
  hist(tmpDiff.v,col="green",main=paste("sample",i,sep=""),xlab=round(mean(tmpDiff.v),2),font.main=1)
  rm(tmpDiff.v,tmp)
}
dev.off()
