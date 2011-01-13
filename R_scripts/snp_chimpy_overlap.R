\author{Gareth Wilson}

snpChimp.v <- vector()
percentVary.v <- vector()
counter <- 1
chrom <- c(1:22,"X")
for (i in chrom){
  chimp.df<-read.table(paste("/path/to/hscpg/human_primates_cpg_miss_nogaps_chr",i,".txt",sep=""),sep="\t",head=F)
  snp.df<-read.table(paste("/path/to/cpg/snp/chr",i,"_val_cpg_snps.txt",sep=""),sep="\t",head=F)
  tmp<-intersect(snp.df$V3,chimp.df$V2)
  snpChimp.v[counter] <- length(tmp)
  percentVary.v[counter] <- length(tmp)/length(chimp.df$V2) * 100
  counter <- counter + 1
}
output.df <- data.frame(chrom,snpChimp.v,percentVary.v)  
colnames(output.df) <- c("Chrom","SNP/primate overlap","Percent of primate")
write.table(output.df,file="/path/to/output/txt",append = FALSE, quote=FALSE, sep="\t", row.names=F,col.names=T)
