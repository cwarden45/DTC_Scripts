args=commandArgs(TRUE);

input.file = args[1]
sample.id = args[2]
segment.file = args[3]
full.norm.file = gsub(".txt$",".norm",segment.file)

library(DNAcopy)

master.table = read.table(input.file, header=T, sep="\t")
pos = (master.table[[2]] + master.table[[3]])/2

master.table = master.table[!duplicated(pos),]
pos = (master.table[[2]] + master.table[[3]])/2

chr = master.table[[1]]
signal = master.table[[5]]

CNA.object = CNA(signal,
                  chr,pos,
                  data.type="logratio",sampleid=sample.id)
smoothed.CNA.object = smooth.CNA(CNA.object)
write.table(data.frame(smoothed.CNA.object), full.norm.file, quote=F, row.names=F, sep="\t")
segment.smoothed.CNA.object = segment(smoothed.CNA.object, verbose=1)
write.table(segment.smoothed.CNA.object$output, segment.file, quote=F, row.names=F, sep="\t")