DNAcopy.folder="../Result/CoNIFER/DNAcopy_sv1"
copy.type="DNAcopy Smoothed CoNIFER SVD-ZRPKM"
window.size = 5000000
cluster.distance = "Pearson_Dissimilarity"

#NOTE: alternate chromosome mapping assumes human - otherwise, you'll probably want to modify sex chromosome re-mapping
library("gplots")

param.table = read.table("parameters.txt", header=T, sep="\t")
fa.file=as.character(param.table$Value[param.table$Parameter == "BWA_Ref"])
meta.file=as.character(param.table$Value[param.table$Parameter == "sample_description_file"])

fa.index = paste(fa.file, ".fai",sep="")

sampleIDs = list.files(DNAcopy.folder)
sampleIDs = sampleIDs[grep(".norm$",sampleIDs)]
sampleIDs = gsub(".norm$","",sampleIDs)

meta.table = read.table(meta.file, head=T, sep="\t")
sample.labels = meta.table$userID[match(sampleIDs, meta.table$sampleID)]
if(length(sample.labels) != length(sample.labels[!is.na(sample.labels)])){
	print("There is a problem mapping sample labels:")
	names(sample.labels)=sampleIDs
	print(sample.labels)
}

chr.table = read.table(fa.index, head=F, sep="\t")
chr.lengths=chr.table$V2
names(chr.lengths)=chr.table$V1
print(length(chr.lengths))
if(length(grep("_",names(chr.lengths)))>0){
	chr.lengths=chr.lengths[-grep("_",names(chr.lengths))]
	print(length(chr.lengths))
}

window.chr = c()
for (i in 1:length(chr.lengths)){
	if(i == 1){
		if(chr.lengths[i] < window.size){
			window.set = paste(names(chr.lengths)[i],":",1,"-",chr.lengths[i],sep="")
			window.chr = names(chr.lengths)[i]
		}else{
			stop("Add code for defining window when first chromosome is larger than window size")
		}
	}else{
		if(chr.lengths[i] < window.size){
			window.set = c(window.set, paste(names(chr.lengths)[i],":",1,"-",chr.lengths[i],sep=""))
			window.chr = c(window.chr, names(chr.lengths)[i])
		}else{
			num.windows = floor(chr.lengths[i]/window.size)
			window.starts = 0:(num.windows-1)*window.size
			window.starts[1]=1
			window.starts = as.integer(window.starts)
			window.starts = as.character(window.starts)
			window.stops = 1:num.windows*window.size-1
			chr.windows = paste(names(chr.lengths)[i],":",window.starts,"-",window.stops,sep="")
			window.set = c(window.set, chr.windows)
			window.chr = c(window.chr, rep(names(chr.lengths)[i],num.windows))
		}
	}#end else
}#end for (i in 1:length(chr.lengths))
print(length(window.set))
window.chr = factor(window.chr, levels = names(chr.lengths))

window.map = function(arr, window.size, chr.lengths){
	window.chr = arr[names(arr)=="chrom"]
	target.pos = as.numeric(arr[names(arr)=="maploc"])
	
	if(target.pos > chr.lengths[names(chr.lengths) == window.chr]){
		return(paste(window.chr,":",1,"-",chr.lengths[names(chr.lengths) == window.chr],sep=""))
	}else{
		max.window = window.size*floor(chr.lengths[names(chr.lengths) == window.chr] / window.size)
		if(target.pos > max.window){
			return(NA)
		}else{
			window.start = as.integer(window.size*(floor(target.pos/window.size)))
			if(window.start == 0){window.start = 1}
			window.stop = as.integer(window.size*(ceiling(target.pos/window.size))-1)
			return(paste(window.chr,":",window.start,"-",window.stop,sep=""))
		}
	}#end else
}#end def window.map

extract.chr = function(char){
	char.info = unlist(strsplit(char,split=":"))
	return(char.info[1])
}#end def extract.chr

for (i in 1:length(sampleIDs)){
	print(sampleIDs[i])
	DNAcopy.file = paste(DNAcopy.folder,"/",sampleIDs[i],".norm",sep="")
	plot.file = paste(DNAcopy.folder,"/",sampleIDs[i],"_median_norm_cov_",window.size,"bp_windows.png",sep="")
	DNAcopy.table = read.table(DNAcopy.file, head=T, sep="\t")
	DNAcopy.table$chrom = as.character(DNAcopy.table$chrom)
	DNAcopy.table$chrom[DNAcopy.table$chrom == "chr23"]="chrX"
	DNAcopy.table$chrom[DNAcopy.table$chrom == "chr24"]="chrY"
	norm.cov = DNAcopy.table[,3]

	Hs.window = apply(DNAcopy.table, 1, window.map, window.size=window.size, chr.lengths=chr.lengths)
	Hs.window = factor(Hs.window, levels=window.set)
	print(length(Hs.window))
	norm.cov = norm.cov[!is.na(Hs.window)]
	Hs.window = Hs.window[!is.na(Hs.window)]
	print(length(Hs.window))
	
	Hs.window.chr = unlist(sapply(as.character(Hs.window),extract.chr))
	Hs.window.chr = factor(Hs.window.chr, levels = names(chr.lengths))
	
	median.per.window = tapply(norm.cov, Hs.window, median, na.rm=T)
	median.per.window = median.per.window[match(window.set, names(median.per.window))]
	med.chr.pos = tapply(as.numeric(as.factor(Hs.window)), Hs.window.chr, median)
	Hs.window.chr = factor(Hs.window.chr, levels = names(med.chr.pos)[!is.na(med.chr.pos)])
	print(length(median.per.window))
	pointCol = as.numeric(as.factor(Hs.window.chr)) %% 2
	pointCol[pointCol == 1]="tan"
	pointCol[pointCol == 0]="gray"
	png(plot.file)
	plot(as.numeric(as.factor(Hs.window)), norm.cov, cex=0.1,
			col=pointCol, pch=16, xaxt= "n",
			ylab=copy.type,xlab="")
	lines(1:length(window.set), median.per.window, lwd=2)
	med.chr.pos=med.chr.pos[!is.na(med.chr.pos)]
	text(med.chr.pos, rep(min(norm.cov,na.rm=T)-0.5,length(med.chr.pos)),
			labels=names(med.chr.pos), xpd=T, srt=90,col=c("tan","gray"),
			cex=0.7)
	dev.off()
	if(i == 1){
		heatmap.mat = median.per.window
	}else{
		heatmap.mat = rbind(heatmap.mat,median.per.window)
	}
}#end for (i in 1:length(sampleIDs))
rownames(heatmap.mat)=sample.labels

col.palette = rep(c("green","orange","purple","cyan","pink","maroon","yellow","red","blue","plum","darkgreen","thistle1","tan","orchid1"),10)

col.chr = unlist(sapply(as.character(colnames(heatmap.mat)),extract.chr))
chr.names = unique(col.chr)
legend.colors = col.palette[1:length(chr.names)]
colColors = rep("black",length(col.chr))
for(i in 1:length(chr.names)){
	colColors[col.chr==chr.names[i]]=legend.colors[i]
}

cor.dist = function(mat){
	cor.mat = cor(as.matrix(t(mat)), use="pairwise.complete.obs")
	dis.mat = 1 - cor.mat
	return(as.dist(dis.mat))	
}#end def cor.dist

if (cluster.distance == "Pearson_Dissimilarity"){
	print("Using Pearson Dissimilarity as Distance in Heatmap...")
	dist.fun = cor.dist
}else{
	dist.fun=dist
}

num.breaks = 33
overall.ab.max = max(abs(heatmap.mat), na.rm=T)
plot.min = -overall.ab.max
plot.max = overall.ab.max
plot.range = plot.max - plot.min
heatmap.breaks = seq(plot.min, plot.max, by=plot.range/num.breaks)
pdf(paste(DNAcopy.folder,"/DNAcopy_normalized_coverage_heatmap.pdf",sep=""))
heatmap.2(heatmap.mat, distfun = dist.fun, hclustfun = hclust,
			 col=colorpanel(num.breaks, low="blue", mid="gray", high="red"),
			 breaks = heatmap.breaks,cexCol=0.1,
			 density.info="none",labCol=rep("",ncol(heatmap.mat)),
			 key=TRUE, Colv=FALSE,
			 ColSideColors=colColors, trace="none",
			 margins = c(20,15), dendrogram="row")
legend("bottom", legend=chr.names, col=legend.colors, ncol=6,
		pch=15, inset=0, xpd=T, cex=0.8)
dev.off()

output.table = data.frame(Window=colnames(heatmap.mat),t(heatmap.mat))
write.table(output.table, paste(DNAcopy.folder,"/DNAcopy_normalized_coverage_heatmap.txt",sep=""),
			row.names=F, quote=F, sep="\t")
