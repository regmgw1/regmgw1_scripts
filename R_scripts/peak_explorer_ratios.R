\author{Gareth Wilson}

input="/path/to/input/txt"
fragmentCount="/path/to/fragment/count/txt"
peaks<-read.table(input,head=T,sep="\t")
counts.df <- read.table(fragmentCount,head=F,sep="\t")
counts.v <- counts.df[,2]
j <- 3
mean.v <- vector()
rpmMean.v <- vector()
for (i in 1:6)
  {
    mean.v[i] <- mean(peaks[,j])
    rpmMean.v[i] <- mean.v[i] * 1000000/counts.v[i]
    j <- j + 3
  }
samples.v <- c("sample10","sample11","sample12","sample7","sample8","sample9")
meanOut.df <- data.frame(samples.v,mean.v,rpmMean.v)
write.table(input,file="mean_rpm_in_peaks",append = TRUE, quote=FALSE, sep="\t", row.names=FALSE,col.names=FALSE)
write.table(meanOut.df,file="mean_rpm_in_peaks",append = TRUE, quote=FALSE, sep="\t", row.names=FALSE,col.names=FALSE)

mmTotal<-peaks$nsc_normalised_sample10_TDG_chr.Both + peaks$nsc_normalised_sample11_TDG_chr.Both + peaks$nsc_normalised_sample12_TDG_chr.Both
mmPos<-peaks$nsc_normalised_sample10_TDG_chr.pos + peaks$nsc_normalised_sample11_TDG_chr.pos + peaks$nsc_normalised_sample12_TDG_chr.pos
mmNeg<-peaks$nsc_normalised_sample10_TDG_chr.neg + peaks$nsc_normalised_sample11_TDG_chr.neg + peaks$nsc_normalised_sample12_TDG_chr.neg
pmTotal<-peaks$nsc_normalised_sample7_TDG_chr.Both + peaks$nsc_normalised_sample8_TDG_chr.Both + peaks$nsc_normalised_sample9_TDG_chr.Both
pmPos<-peaks$nsc_normalised_sample7_TDG_chr.pos + peaks$nsc_normalised_sample8_TDG_chr.pos + peaks$nsc_normalised_sample9_TDG_chr.pos
pmNeg<-peaks$nsc_normalised_sample7_TDG_chr.neg + peaks$nsc_normalised_sample8_TDG_chr.neg + peaks$nsc_normalised_sample9_TDG_chr.neg

mmTotal<-peaks$es_normalised_sample4_TDG_chr.Both + peaks$es_normalised_sample5_TDG_chr.Both + peaks$es_normalised_sample6_TDG_chr.Both
mmPos<-peaks$es_normalised_sample4_TDG_chr.pos + peaks$es_normalised_sample5_TDG_chr.pos + peaks$es_normalised_sample6_TDG_chr.pos
mmNeg<-peaks$es_normalised_sample4_TDG_chr.neg + peaks$es_normalised_sample5_TDG_chr.neg + peaks$es_normalised_sample6_TDG_chr.neg
pmTotal<-peaks$es_normalised_sample1_TDG_chr.Both + peaks$es_normalised_sample2_TDG_chr.Both + peaks$es_normalised_sample3_TDG_chr.Both
pmPos<-peaks$es_normalised_sample1_TDG_chr.pos + peaks$es_normalised_sample2_TDG_chr.pos + peaks$es_normalised_sample3_TDG_chr.pos
pmNeg<-peaks$es_normalised_sample1_TDG_chr.neg + peaks$es_normalised_sample2_TDG_chr.neg + peaks$es_normalised_sample3_TDG_chr.neg


mmTotal<-peaks$normalised_MEF4.Both + peaks$normalised_MEF5.Both + peaks$normalised_MEF6.Both
mmPos<-peaks$normalised_MEF4.pos + peaks$normalised_MEF5.pos + peaks$normalised_MEF6.pos
mmNeg<-peaks$normalised_MEF4.neg + peaks$normalised_MEF5.neg + peaks$normalised_MEF6.neg
pmTotal<-peaks$normalised_MEF1.Both + peaks$normalised_MEF2.Both + peaks$normalised_MEF3.Both
pmPos<-peaks$normalised_MEF1.pos + peaks$normalised_MEF2.pos + peaks$normalised_MEF3.pos
pmNeg<-peaks$normalised_MEF1.neg + peaks$normalised_MEF2.neg + peaks$normalised_MEF3.neg

mmPos<-replace(mmPos,mmPos==0,1)
pmPos<-replace(pmPos,pmPos==0,1)
pmNeg<-replace(pmNeg,pmNeg==0,1)
mmNeg<-replace(mmNeg,mmNeg==0,1)
mmRat<-log2(mmPos/mmNeg)
jpeg("reduced_strandRatio_mef_mm_FDR13.jpg")
hist(mmRat,breaks=20,col="red",main="Log2 ratio of pos/neg for MEFmm",xlab="Log2 ratio")
dev.off()
pmRat<-log2(pmPos/pmNeg)
jpeg("reduced_strandRatio_mef_pm_FDR13.jpg")
hist(pmRat,breaks=100,col="blue",main="Log2 ratio of pos/neg for MEFpm",xlab="Log2 ratio")
dev.off()
totalPos <- mmPos + pmPos
totalNeg <- mmNeg + pmNeg
total.idx <- which(totalPos + totalNeg > 0)
totalPos <- replace(totalPos,totalPos==0,1)
totalNeg <- replace(totalNeg,totalNeg==0,1)
totalRat <- log2(totalPos[total.idx]/totalNeg[total.idx])
totalRat <- log2(totalPos/totalNeg)
quantile(totalRat,probs = seq(0, 1, 0.05))
jpeg("random_strandRatio_esc.jpg")
hist(totalRat,breaks=20,col="green",main="Log2 ratio of pos/neg for random regions ESC",xlab="Log2 ratio")
dev.off()
s10rat <- log2(peaks$nsc_normalised_sample10_TDG_chr.pos/peaks$nsc_normalised_sample10_TDG_chr.neg)
hist(s10rat,breaks=100,col="red",main="Log2 ratio of pos/neg for S10mm",xlab="Log2 ratio")
s11rat <- log2(peaks$nsc_normalised_sample11_TDG_chr.pos/peaks$nsc_normalised_sample11_TDG_chr.neg)
hist(s11rat,breaks=100,col="red",main="Log2 ratio of pos/neg for S11mm",xlab="Log2 ratio")
s12rat <- log2(peaks$nsc_normalised_sample12_TDG_chr.pos/peaks$nsc_normalised_sample12_TDG_chr.neg)
hist(s12rat,breaks=100,col="red",main="Log2 ratio of pos/neg for S12mm",xlab="Log2 ratio")

# Generate output files for non_CpG peaks and CpG peaks based on predetermined thresholds
thresh <- c(-2.757,2.662)
tmp <- (totalRat>thresh[2] | totalRat< thresh[1])
peaks2 <- data.frame(peaks,tmp)
single.df <- peaks2[peaks2$tmp==TRUE,]
cpg.df <- peaks2[peaks2$tmp==FALSE,]
write.table(single.df,file="non_CpG_peaks.txt", quote=FALSE, sep="\t", row.names=FALSE,col.names=TRUE)
write.table(cpg.df,file="CpG_peaks.txt", quote=FALSE, sep="\t", row.names=FALSE,col.names=TRUE)

qqplot(totalRat,totalRatNscHyper)


# plot histogram of % difference in read count between two cohort totals

perDiffReads <- 100-((pmTotal/mmTotal) *100)
brk.pts <- c(-1,10,20,30,40,50,60,70,80,90,100)
binLabels <- c("0-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100")
bins <- cut(perDiffReads,brk.pts)
jpeg("npc_enriched_mm_depth10_perDiff.jpg")
barplot(table(bins),names.arg=binLabels,xlab="Percent Difference in Reads in Cohort NPCmm - NPCpm (Depth 10)")
dev.off()
