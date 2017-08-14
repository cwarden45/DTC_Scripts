window.size = 5000000
max.cov = 400
plot.min = -3
plot.max = 3
log2.rounding.value = 0.1
cluster.distance = "Pearson_Dissimilarity"

library("gplots")

param.table = read.table("parameters.txt", header=T, sep="\t")
alignment.folder = as.character(param.table$Value[param.table$Parameter == "Alignment_Folder"])
fa.file=as.character(param.table$Value[param.table$Parameter == "BWA_Ref"])
meta.file=as.character(param.table$Value[param.table$Parameter == "sample_description_file"])

fa.index = paste(fa.file, ".fai",sep="")

sampleIDs = list.files(alignment.folder)
sampleIDs = sampleIDs[grep(".nodup.bam$",sampleIDs)]
sampleIDs = gsub(".nodup.bam$","",sampleIDs)

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
	target.stop = as.numeric(arr[names(arr)=="end"])
	
	if(target.stop > chr.lengths[names(chr.lengths) == window.chr]){
		return(paste(window.chr,":",1,"-",chr.lengths[names(chr.lengths) == window.chr],sep=""))
	}else{
		target.start = as.numeric(arr[names(arr)=="start"])
		target.mid = (target.start + target.stop)/2
		max.window = window.size*floor(chr.lengths[names(chr.lengths) == window.chr] / window.size)
		if(target.mid > max.window){
			return(NA)
		}else{
			window.start = as.integer(window.size*(floor(target.mid/window.size)))
			if(window.start == 0){window.start = 1}
			window.stop = as.integer(window.size*(ceiling(target.mid/window.size))-1)
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
	Hs.file = paste(alignment.folder,"/",sampleIDs[i],"/HsMetrics_coverage_stats_per_target_no_dup.txt",sep="")
	plot.file = paste(alignment.folder,"/",sampleIDs[i],"/HsMetrics_median_coverage_per_million_",window.size,"bp_windows.png",sep="")
	Hs.table = read.table(Hs.file, head=T, sep="\t")
	Hs.table$mean_coverage[Hs.table$mean_coverage > max.cov]=max.cov
	approx.million.total.reads = sum(Hs.table$read_count)/1000000
	
	cov.per.million = log2(Hs.table$mean_coverage / approx.million.total.reads + log2.rounding.value)
	
	Hs.window = apply(Hs.table, 1, window.map, window.size=window.size, chr.lengths=chr.lengths)
	Hs.window = factor(Hs.window, levels=window.set)
	print(length(Hs.window))
	cov.per.million = cov.per.million[!is.na(Hs.window)]
	Hs.window = Hs.window[!is.na(Hs.window)]
	print(length(Hs.window))
	
	Hs.window.chr = unlist(sapply(as.character(Hs.window),extract.chr))
	Hs.window.chr = factor(Hs.window.chr, levels = names(chr.lengths))
	
	median.per.window = tapply(cov.per.million, Hs.window, median, na.rm=T)
	median.per.window = median.per.window[match(window.set, names(median.per.window))]
	med.chr.pos = tapply(as.numeric(as.factor(Hs.window)), Hs.window.chr, median)
	Hs.window.chr = factor(Hs.window.chr, levels = names(med.chr.pos)[!is.na(med.chr.pos)])
	print(length(median.per.window))
	pointCol = as.numeric(as.factor(Hs.window.chr)) %% 2
	pointCol[pointCol == 1]="tan"
	pointCol[pointCol == 0]="gray"
	png(plot.file)
	plot(as.numeric(as.factor(Hs.window)), cov.per.million, cex=0.1,
			col=pointCol, pch=16, xaxt= "n",ylim=c(plot.min,plot.max),
			ylab=paste("log2( Target Coverage per Million Reads + ",log2.rounding.value,")",sep=""),
			xlab="")
	lines(1:length(window.set), median.per.window, lwd=2)
	med.chr.pos=med.chr.pos[!is.na(med.chr.pos)]
	text(med.chr.pos, rep(plot.min-0.5,length(med.chr.pos)),
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
plot.range = plot.max - plot.min
heatmap.breaks = seq(plot.min, plot.max, by=plot.range/num.breaks)
pdf("HsMetrics_normalized_coverage_heatmap.pdf")
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
write.table(output.table, "HsMetrics_normalized_coverage_heatmap.txt",
			row.names=F, quote=F, sep="\t")
