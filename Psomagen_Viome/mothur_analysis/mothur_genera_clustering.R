#input.file = "16S_2021.trim.contigs.good.unique.nr_v132.wang.tax.summary"
#SampleNum=c("S1","S2","S3","S2","S3","S3","S4")
#Company=c("Psomagen","Psomagen","Psomagen","thryve","thryve","thryve","thryve")
###starting_count = 40000
##input.file = "FQ_40k_reads-SILVA_seed/16S_2021.trim.contigs.good.unique.seed_v132.wang.tax.summary"
##input.file = "FQ_40k_reads-SILVA_full/16S_2021.trim.contigs.good.unique.nr_v132.wang.tax.summary"
##input.file = "FQ_40k_reads-SILVA_full_70conf/16S_2021.trim.contigs.good.unique.nr_v132.wang.tax.summary"
##input.file = "FQ_40k_reads-SILVA_full_50conf/16S_2021.trim.contigs.good.unique.nr_v132.wang.tax.summary"
##input.file = "FQ_40k_reads-RDP/16S_2021.trim.contigs.good.unique.rdp.wang.tax.summary"
#output.percent_quantified = "n7_SILVA_filtered_genera-percent_quantified.txt"
#heatmap.output_quantified = "n7_SILVA_filtered_genera-heatmap_quantified.pdf"
#min.percent = 0.5

input.file = "16S_2021.trim.contigs.good.unique.nr_v132.wang.tax.summary"
SampleNum=c("S1","S2","S3","S4","S2","S3","S3","S4")
Company=c("Psomagen","Psomagen","Psomagen","Psomagen","thryve","thryve","thryve","thryve")
output.percent_quantified = "n8_SILVA_filtered_genera-percent_quantified.txt"
heatmap.output_quantified = "n8_SILVA_filtered_genera-heatmap_quantified.pdf"
min.percent = 0.5


#uses R v3.6.3 and gplots v3.1.1
library(gplots)

input.table = read.table(input.file, head=T, sep="\t")

classified.totals = input.table[1,6:ncol(input.table)]
print(classified.totals)

##Actinobacteria_unclassified appears twice
#print(table(input.table$rankID == "0.2.1.1.1.1.1"))
#print(table(input.table$rankID == "0.2.1.2.1.1.1"))
input.table$total[input.table$rankID == "0.2.1.1.1.1.1"]=input.table$total[input.table$rankID == "0.2.1.1.1.1.1"]+input.table$total[input.table$rankID == "0.2.1.2.1.1.1"]
input.table = input.table[input.table$rankID != "0.2.1.2.1.1.1",]

genus_names = input.table$taxon[input.table$taxlevel==6]
genus_counts = input.table[input.table$taxlevel==6,6:ncol(input.table)]
print(dim(genus_counts))
genus_counts = genus_counts[(genus_names != "uncultured")&(genus_names != "unknown_unclassified")&(genus_names != "Eukaryota_unclassified")&(genus_names != "Bacteria_unclassified"),]
genus_names = genus_names[(genus_names != "uncultured")&(genus_names != "unknown_unclassified")&(genus_names != "Eukaryota_unclassified")&(genus_names != "Bacteria_unclassified")]
rownames(genus_counts)=genus_names

#avoids getting very high unclassified counts for Psomagen
classified.totals = apply(genus_counts, 2, sum)
print(classified.totals)

#Quantified Plots
genus_percent.quantified = genus_counts
for (i in 1:nrow(genus_percent.quantified)){
	genus_percent.quantified[i,]=100 * genus_counts[i,]/classified.totals
}#end for (i in 1:nrow(genus_percent.quantified))
write.table(data.frame(Genus=genus_names, genus_percent.quantified), output.percent_quantified, quote=F, sep="\t", row.names=F)
print(dim(genus_percent.quantified))
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