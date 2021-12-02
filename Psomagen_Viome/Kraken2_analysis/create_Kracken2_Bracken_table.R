input_folder = "output_files"
SampleNum=c("S1","S2","S3","S4","S2","S3","S3","S4")
Company=c("Psomagen","Psomagen","Psomagen","Psomagen","thryve","thryve","thryve","thryve")
output.classification_rate = "n8_Kraken2-Bacterial_Classifications.txt"
output.percent_quantified = "n8_Braken2_genera-percent_quantified.txt"
heatmap.output_quantified = "n8_Braken2_genera-heatmap_quantified.pdf"
min.percent = 0.5

classification.rate = c()
Kraken2_files = list.files(input_folder,"_Kraken2.kreport")
for (i in 1:length(Kraken2_files)){
	Kraken2_table = read.table(paste(input_folder,Kraken2_files[i],sep="/"), head=F, sep="\t")
	classification.rate[i]=Kraken2_table$V1[Kraken2_table$V6 == "    Bacteria"]
}#end for (i in 1:length(Kraken2_files))

classification.table = data.frame(Sample=gsub("_Kraken2.kreport","",Kraken2_files),Classification_Rate=classification.rate)
write.table(classification.table, output.classification_rate, quote=F, sep="\t", row.names=F)

Bracken_files = list.files(input_folder,"_Kraken2_bracken.kreport")
for (i in 1:length(Bracken_files)){
	sampleID = gsub("_Kraken2_bracken.kreport","",Bracken_files[i])
	Bracken_table = read.table(paste(input_folder,Bracken_files[i],sep="/"), head=F, sep="\t")
	Genera_table = Bracken_table[Bracken_table$V4 == "G",]
	#print(dim(Genera_table))
	Genera_table$V6 = gsub("\\s+","",as.character(Genera_table$V6))
	Genera_table = Genera_table[!is.na(Genera_table$V6),]
	Genera_table = Genera_table[Genera_table$V6 != "",]
	#print(dim(Genera_table))
	sample_genera = gsub("\\s+","",as.character(Genera_table$V6))
	sample_percent = as.numeric(as.character(Genera_table$V1))
	
	if (i==1){
		percent_quantified_table = data.frame(Genus=as.character(sample_genera), sampleID=sample_percent)
		colnames(percent_quantified_table)[i+1]=sampleID
		print(dim(percent_quantified_table))
		percent_quantified_table$Genus=as.character(percent_quantified_table$Genus)
	}else{
		prev_genus = as.character(percent_quantified_table$Genus)
		shared_genera = union(prev_genus,sample_genera)
		percent_quantified_table = percent_quantified_table[match(shared_genera,prev_genus),]
		
		percent_quantified_table = data.frame(percent_quantified_table,
												sampleID=sample_percent[match(shared_genera,sample_genera)])
		percent_quantified_table$Genus = as.character(shared_genera)
		colnames(percent_quantified_table)[i+1]=sampleID
		print(dim(percent_quantified_table))
	}#end else
	#print(tail(percent_quantified_table))
}#end for (i in 1:length(Bracken_files))

Bracken_files = list.files(input_folder,"_Kraken2_bracken.kreport")
for (i in 1:length(Bracken_files)){
	sample_percent = percent_quantified_table[,i+1]
	sample_percent[is.na(sample_percent)]=0
	percent_quantified_table[,i+1]=sample_percent
}#end for (i in 1:length(Bracken_files))

genera_counts = table(percent_quantified_table$Genus)
print(genera_counts[genera_counts != 1])


#based largely on https://github.com/cwarden45/DTC_Scripts/blob/master/Psomagen_Viome/mothur_analysis/mothur_genera_clustering.R
#uses R v3.6.3 and gplots v3.1.1
library(gplots)

genus_percent.quantified = percent_quantified_table[,2:ncol(percent_quantified_table)]
rownames(genus_percent.quantified)=percent_quantified_table$Genus
max_percentage = apply(genus_percent.quantified, 1, max)
genus_percent.quantified = genus_percent.quantified[max_percentage > min.percent,]
print(dim(genus_percent.quantified))

sampleCol=rep("black",length(SampleNum))
sampleCol[SampleNum == "S1"]=rainbow(5)[2]
sampleCol[SampleNum == "S2"]=rainbow(5)[3]
sampleCol[SampleNum == "S3"]=rainbow(5)[4]
sampleCol[SampleNum == "S4"]=rainbow(5)[5]

companyCol=rep("black",length(SampleNum))
companyCol[Company == "Psomagen"]="darkgreen"
companyCol[Company == "thryve"]="darkorange"

source("heatmap.3.R")

column_annotation = as.matrix(data.frame(Sample = sampleCol,Company = companyCol))
colnames(column_annotation)=c("Sample","Company")

pdf(heatmap.output_quantified)
heatmap.3(genus_percent.quantified,   distfun = dist, hclustfun = hclust,
			col=colorpanel(33, low="black", mid="pink", high="red"), density.info="none", key=TRUE,
			ColSideColors=column_annotation, ColSideColorsSize=2, cexRow=0.5,
			trace="none", margins = c(15,10), dendrogram="both")
legend("bottom", pch=15, ncol=4, pt.cex=1, xpd=T,inset=-0.14,
		legend=c("Psomagen","Sample1","thryve","Sample2","","Sample3","","Sample4"),
		col=c("darkgreen",rainbow(5)[2],"darkorange",rainbow(5)[3],"white",rainbow(5)[4],"white",rainbow(5)[5]))
dev.off()