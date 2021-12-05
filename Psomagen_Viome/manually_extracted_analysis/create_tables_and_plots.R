input.file = "signature_summary.txt"
output.file1 = "signature_summary-same_sample.txt"
output.file2 = "signature_summary-1to3_vs_4.txt"
overall.plot = "all_signatures.png"
overall.plot2 = "all_signatures-heatmap.png"
same_sample.plot = "signature_summary-same_sample.png"

input.table = read.table(input.file, head=T, sep="\t")

print(input.table$Value[1:10])
input.table$Value[input.table$Value == "Not in Screenshots"]=NA
input.table$Value[input.table$Value == "Not Reported"]=NA
input.table$Value = as.numeric(as.character(input.table$Value))
print(input.table$Value[1:10])

pointCol = rep("black",nrow(input.table))
pointCol[input.table$Company == "Viome"]="gray"
pointCol[input.table$Company == "Psomagen"]="cyan"
pointCol[input.table$Company == "thryve"]="green"

input.table$Sample[input.table$Sample == "3"]="3a"
print(table(input.table$Sample))
input.table$Sample=factor(as.character(input.table$Sample),
							levels=c("1a","1b","2","3a","3b","4"))

png(overall.plot)
plot(as.numeric(input.table$Sample), input.table$Value,
	pch=16, col=pointCol, xaxt='n', xlab="Sample", ylab="Signature/Score Value")
mtext(text=levels(input.table$Sample), side=1, at=1:length(levels(input.table$Sample)))
sig_names = paste(input.table$Company,input.table$Score.Signature)
print(sig_names)
for (i in 1:length(unique(sig_names))){
	print(sig_names[i])
	sig_table = input.table[sig_names == unique(sig_names)[i],]
	sig_company = sig_table$Company[1]
	#print(sig_company)
	line_col = "black"
	if(sig_company == "Viome"){
		line_col = "gray"
	}else if(sig_company == "Psomagen"){
		line_col = "cyan"
	}else if(sig_company == "thryve"){
		line_col = "green"
	}
	#print(line_col)
	lines(as.numeric(sig_table$Sample), sig_table$Value,lwd=1, col=line_col)
}#end for (i in 1:levels(input.table$Score.Signature))
dev.off()

#overall heatmap
sample_table = table(sig_names, input.table$Sample)
for(sampleID in levels(input.table$Sample)){
	#print(sampleID)
	temp_sample_table = input.table[input.table$Sample == sampleID,]
	temp_sig_names = paste(temp_sample_table$Company,temp_sample_table$Score.Signature)
	sample_table[,sampleID]=temp_sample_table$Value[match(rownames(sample_table), temp_sig_names)]
}#end for(sampleID in levels(input.table$Sample))

library(gplots)

png(overall.plot2)
heatmap.2(sample_table, Rowv=F, Colv=F, dendrogram="none", trace="none",
			margins = c(5,20), na.color="gray80")
dev.off()

#replicates for same sample
reps1.mean=tapply(input.table$Value[grep("1",input.table$Sample)], sig_names[grep("1",input.table$Sample)], mean)
reps1.mean = reps1.mean[grep("Viome",names(reps1.mean))]
reps1.sd=tapply(input.table$Value[grep("1",input.table$Sample)], sig_names[grep("1",input.table$Sample)], sd)
reps1.sd = reps1.sd[grep("Viome",names(reps1.sd))]

reps3.mean=tapply(input.table$Value[grep("3",input.table$Sample)], sig_names[grep("3",input.table$Sample)], mean)
reps3.mean = reps3.mean[grep("thryve",names(reps3.mean))]
reps3.sd=tapply(input.table$Value[grep("3",input.table$Sample)], sig_names[grep("3",input.table$Sample)], sd)
reps3.sd = reps3.sd[grep("thryve",names(reps3.sd))]

same_sample.table = data.frame(Sig=c(names(reps1.mean),names(reps3.mean)),
								Mean=c(reps1.mean,reps3.mean),
								SD=c(reps1.sd,reps3.sd))
same_sample.table=same_sample.table[same_sample.table$Sig != "thryve Bacteria Optimal Percent",]#only 2 recorded measurements (not saved for sample 3)
write.table(same_sample.table, output.file1, quote=F, row.names=F, sep="\t")

ptCol=rep("black",nrow(same_sample.table))
ptCol[grep("Viome",same_sample.table$Sig)]="gray"
ptCol[grep("thryve",same_sample.table$Sig)]="green"

png(same_sample.plot)
plot(same_sample.table$Mean, same_sample.table$SD,
	xlab="Same Sample (Mean)",ylab="Same Sample (SD)",main="",
	pch=16, col=ptCol, xlim=c(0,100), cex=2)
legend("top",legend=c("Viome","thryve"),col=c("gray","green"), pch=16,
		xpd=T, inset=-0.1, ncol=2)
abline(h=2, col="orange",lty=2)
dev.off()

#1to3 versus 4
sample4 = input.table$Value[input.table$Sample == "4"]
names(sample4)=sig_names[input.table$Sample == "4"]
sample4=sample4[match(unique(sig_names), names(sample4))]

sample1to3.median=tapply(input.table$Value[input.table$Sample != "4"], sig_names[input.table$Sample != "4"], median)
sample1to3.median = sample1to3.median[match(unique(sig_names),names(sample1to3.median))]

sample1to3.mean=tapply(input.table$Value[input.table$Sample != "4"], sig_names[input.table$Sample != "4"], mean)
sample1to3.mean = sample1to3.mean[match(unique(sig_names),names(sample1to3.mean))]

sample1to3.sd=tapply(input.table$Value[input.table$Sample != "4"], sig_names[input.table$Sample != "4"], sd)
sample1to3.sd = sample1to3.sd[match(unique(sig_names),names(sample1to3.sd))]

sample4.z=(sample4 - sample1to3.mean)/sample1to3.sd

output.table2 = data.frame(Sig=unique(sig_names),
							sample1to3.median, sample1to3.mean, sample1to3.sd,
							Sample4=sample4, sample4.z)
output.table2=output.table2[output.table2$Sig != "thryve Bacteria Optimal Percent",]#only 2 recorded measurements
output.table2=output.table2[output.table2$Sig != "Viome Microbiome-Induced Stress",]#not in report for sample 4
write.table(output.table2, output.file2, quote=F, row.names=F, sep="\t")