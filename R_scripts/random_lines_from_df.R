\author{Gareth Wilson}

# PE
data <- read.table("/path/to/bed",head=FALSE,sep="\t")
half <- round(nrow(data)/2)
randData <- data[sample(1:nrow(data), nrow(data), replace = FALSE),]
first <- randData[1:half,]
second <- randData[(half+1):nrow(data),]
firstO <- first[order(first$V4),]
secondO <- second[order(second$V4),]
write.table(firstO,file="/path/to/output/first/txt",append = FALSE, quote=FALSE, sep="\t", row.names=FALSE,col.names=FALSE)
write.table(secondO,file="/path/to/output/second/txt",append = FALSE, quote=FALSE, sep="\t", row.names=FALSE,col.names=FALSE)

# SE
data <- read.table("/path/to/gff",head=FALSE,sep="\t")
half <- round(nrow(data)/2)
randData <- data[sample(1:nrow(data), nrow(data), replace = FALSE),]
first <- randData[1:half,]
second <- randData[(half+1):nrow(data),]
firstO <- first[order(first$V4),]
secondO <- second[order(second$V4),]
write.table(firstO,file="/path/to/output/first/txt",append = FALSE, quote=FALSE, sep="\t", row.names=FALSE,col.names=FALSE
write.table(secondO,file="/path/to/output/second/txt",append = FALSE, quote=FALSE, sep="\t", row.names=FALSE,col.names=FALSE)
