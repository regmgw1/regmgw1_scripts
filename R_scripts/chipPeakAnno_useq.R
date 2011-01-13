\author{Gareth Wilson}

library(ChIPpeakAnno)
input <- "binaryWindowData_FDR3.0_Log2Ratio0.0010_13973"
path2Input <- "/my/path/to/input/dir"
peaks.df <- read.table(paste(path2Input,"/",input,".gff",sep=""),sep="\t",skip=4,header=F)
peaks.range <- GFF2RangedData(peaks.df,header=F)

###use code for generating gene lists and GO files
#feature.range <- GFF2RangedData(transcripts.df,header=F)
data(TSS.mouse.NCBIM37)
tss.range <- TSS.mouse.NCBIM37
annotatedPeaknon<-annotatePeakInBatch(peaks.range,AnnotationData=tss.range,output="both",multiple=T,maxgap=0)
annotatedPeakEnsTSS<-annotatePeakInBatch(peaks.range,AnnotationData=tss.range,output="both",multiple=T,maxgap=0)
pie(table(as.data.frame(annotatedPeakEnsTSS)$insideFeature))
distToNearestFeat <- annotatedPeak$distancetoFeature[!is.na(annotatedPeak$distancetoFeature) & annotatedPeak$fromOverlappingOrNearest == "NearestStart"]
#hist(distToNearestFeat,xlab="Distance to nearest transcript",main="",breaks=1000,xlim=c(min(distToNearestFeat)-100,max(distToNearestFeat)+100))
hist(distToNearestFeat,xlab="Distance to nearest transcript",main="",breaks=10000,xlim=c(-5000,5000))
ensembl = useMart("ensembl",dataset="mmusculus_gene_ensembl")
annotatedPeakEnsTSS.df <- as.data.frame(annotatedPeakEnsTSS)
annotatedPeakEnsTSS.df <- annotatedPeakEnsTSS.df[order(annotatedPeakEnsTSS.df$peak),]
ensMgi <- getBM(attributes = c("mgi_symbol","ensembl_gene_id"), filters = "ensembl_gene_id", values=annotatedPeakEnsTSS.df$feature[1],mart=ensembl)
tmp <- cbind(as.data.frame(annotatedPeakEnsTSS.df[1,]),ensMgi)
geneIds <- tmp
#ensMgi <- getBM(attributes = c("mgi_symbol", "entrezgene","ensembl_gene_id"), filters = "ensembl_gene_id", values=annotatedPeakEnsTSS$feature,mart=ensembl)
#for (i in 1:dim(annotatedPeakEnsTSS)[1]){
for (i in 2:dim(annotatedPeakEnsTSS.df)[1]){
  ensMgi <- getBM(attributes = c("mgi_symbol","ensembl_gene_id"), filters = "ensembl_gene_id", values=annotatedPeakEnsTSS.df$feature[i],mart=ensembl)
  if (dim(ensMgi)[1] > 0)
  for (j in 1:dim(ensMgi)[1]){
    tmp <- cbind(as.data.frame(annotatedPeakEnsTSS.df[i,]),ensMgi[j,])
    geneIds <- rbind(geneIds,tmp)
  }
  else print ("No matching ID")
}

write.table(geneIds,file=paste("annotatedPeaks_",input,".txt",sep=""),append = FALSE, quote=FALSE, sep="\t", row.names=F,col.names=T)

library(org.Mm.eg.db)
enrichedGO <- getEnrichedGO(annotatedPeakEnsTSS,orgAnn="org.Mm.eg.db",maxP=0.1,multiAdj=TRUE,minGOterm=5,multiAdjMethod="BH")
#enrichedGO <- getEnrichedGO(annotatedPeakEnsTSS,orgAnn="org.Mm.eg.db",maxP=0.01,multiAdj=F,minGOterm=5)
write.table(enrichedGO$bp,file=paste("enrichedGO_BP_",input,".txt",sep=""),append = FALSE, quote=FALSE, sep="\t", row.names=F,col.names=T)
write.table(enrichedGO$mf,file=paste("enrichedGO_MF_",input,".txt",sep=""),append = FALSE, quote=FALSE, sep="\t", row.names=F,col.names=T)
write.table(enrichedGO$cc,file=paste("enrichedGO_CC_",input,".txt",sep=""),append = FALSE, quote=FALSE, sep="\t", row.names=F,col.names=T)


# use code for counting feature overlaps
path2FeaturesDir <- "/path/to/features/dir"
features.v <- c("cpg_islands","cpg_shores_2000","exons","introns","intergenic","repeat_family","transcripts","trans_proms")
#features.v <- c("cpg_islands","cpg_shores_2000")
count.df <- data.frame()
for (i in 3:length(features.v)){
  features.df <- read.table(paste(path2FeaturesDir,"/",features.v[i],"/",features.v[i],".gff",sep=""),sep="\t",header=F)
  feature.range <- GFF2RangedData(features.df,header=F)
  annotatedPeak<-annotatePeakInBatch(peaks.range,AnnotationData=feature.range,output="overlapping",multiple=T,maxgap=0)
  if (i == 1)
  count.df <- summary(as.factor(annotatedPeak$insideFeature))
  else
    count.df<- data.frame(count.df,summary(as.factor(annotatedPeak$insideFeature)))
}
count.df <- t(count.df)
row.names(count.df) <- features.v

library(BSgenome.Mmusculus.UCSC.mm9)
peaksWithSeqs <- getAllPeakSequence(peaks.range,upstream=50,downstream=50,genome=Mmusculus)
write2FASTA(peaksWithSeqs,file="peak_seqs.fasta",width=50)
