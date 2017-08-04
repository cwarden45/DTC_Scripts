annotated.folder = "../Result/Separate_GATK_Variant_Calls"
summary.file = "ANNOVAR_variant_summary.txt"

param.table = read.table("parameters.txt", header=T, sep="\t")
genome = as.character(param.table$Value[param.table$Parameter == "genome"])

annotated.folders = list.dirs(annotated.folder)
annotated.folders = annotated.folders[annotated.folders != annotated.folder]

annotated.samples = gsub(annotated.folder,"",annotated.folders)
annotated.samples = gsub("/","",annotated.samples)
annotated.samples = gsub("\\\\","",annotated.samples)

output.samples = c()
exonic.count = c()
kaviar.gnomAD.rare.count = c()
sift.polyphen.damaging.count = c()
damaging.count = c()
cosmic.count = c()
nci60.count = c()
clinvar.count = c()
gwas.catalog.count = c()
oreganno.count = c()

for (i in 1:length(annotated.samples)){
	annotated.folder = annotated.folders[i]
	sampleID = annotated.samples[i]
	
	annovar.csv = file.path(annotated.folder, paste(sampleID,".",genome,"_multianno.csv",sep=""))
	annovar.gwas = file.path(annotated.folder, paste(sampleID,"_annovar_GWAS_Catalog.",genome,"_bed",sep=""))
	bedtools.oreganno = file.path(annotated.folder, paste(sampleID,"_bedtools_ORegAnno.avinput",sep=""))
	
	if(file.exists(annovar.csv)&file.exists(annovar.gwas)&file.exists(bedtools.oreganno)){
		print(sampleID)
		output.samples=c(output.samples,sampleID)
		
		big.table = read.csv(annovar.csv)
		other.info.mat = matrix(unlist(strsplit(as.character(big.table$Otherinfo),split="\t")),ncol=3, byrow=T)
		colnames(other.info.mat)=c("genotype","variant.quality.score","coverage")
		big.table = data.frame(big.table[,1:5],other.info.mat,big.table[,6:(ncol(big.table)-1)])
		
		exonic.count = c(exonic.count, length(big.table$Func.refGene[big.table$Func.refGene == "exonic"]))
		clinvar.count = c(clinvar.count, length(big.table$CLINSIG[!is.na(big.table$CLINSIG)]))
		cosmic.count = c(cosmic.count, length(big.table$cosmic70[!is.na(big.table$cosmic70)]))
		nci60.count = c(nci60.count, length(big.table$nci60[!is.na(big.table$cosmic70)]))
		
		annovarID = paste(big.table$Chr,big.table$Start,big.table$End,big.table$Ref,big.table$Alt,sep="\t")
		#rsID = as.character(big.table$avsnp147)
		
		rare.flag = rep(0, nrow(big.table))
		#assume NA is low frequency
		big.table$gnomAD_exome_ALL = as.character(big.table$gnomAD_exome_ALL)
		big.table$gnomAD_exome_ALL[is.na(big.table$gnomAD_exome_ALL)]=0
		big.table$gnomAD_exome_ALL = as.numeric(big.table$gnomAD_exome_ALL)
		rare.flag[(big.table$Kaviar_AF < 0.01)&(big.table$gnomAD_exome_ALL < 0.01)] = 1
		kaviar.gnomAD.rare.count = c(kaviar.gnomAD.rare.count, length(rare.flag[rare.flag == 1]))
		
		damaging.flag = rep(0, nrow(big.table))
		damaging.flag[(!is.na(big.table$SIFT_pred) & (big.table$SIFT_pred == "D")) | (!is.na(big.table$Polyphen2_HDIV_pred) & (big.table$Polyphen2_HDIV_pred == "D"))| (!is.na(big.table$Polyphen2_HVAR_pred) & (big.table$Polyphen2_HVAR_pred == "D")) | (!is.na(big.table$ExonicFunc.refGene)&((big.table$ExonicFunc.refGene == "frameshift insertion")|(big.table$ExonicFunc.refGene == "frameshift deletion")|(big.table$ExonicFunc.refGene == "stopgain")))] = 1
		damaging.count=c(damaging.count,length(damaging.flag[damaging.flag==1]))
		
		rare.damaging.flag = rep(0, nrow(big.table))
		rare.damaging.flag[(rare.flag == 1) & (damaging.flag == 1)] = 1
		exonic.rare.damaging.count = c(exonic.rare.damaging.count, length(rare.damaging.flag[rare.damaging.flag==1]))
		
		gwas.table = read.delim(annovar.gwas, head=F)
		gwas.rsID = as.character(gwas.table[,2])
		gwas.rsID = gsub("Name=","",gwas.rsID)
		gwas.catalog.count = c(gwas.catalog.count, length(gwas.rsID))
		gwas.annovarID = paste(gwas.table[,3],gwas.table[,4],gwas.table[,5],gwas.table[,6],gwas.table[,7],sep="\t")
		gwas.rsID = gwas.rsID[match(annovarID,gwas.annovarID)]
		
		oreganno.table = read.delim(bedtools.oreganno, head=F)
		oregannoID = oreganno.table[,8]
		oreganno.count = c(oreganno.count, length(oregannoID))
		oreganno.annovarID = paste(oreganno.table[,1],oreganno.table[,2],oreganno.table[,3],oreganno.table[,4],oreganno.table[,5],sep="\t")
		oregannoID = oregannoID[match(annovarID,oreganno.annovarID)]
		
		extra.table = data.frame(big.table, gwas.catalog = gwas.rsID, oreganno = oregannoID, exonic.rare.damaging.flag = rare.damaging.flag)
		extra.file = file.path(annotated.folder, paste(sampleID,"_combined_summary.txt",sep=""))
		write.table(extra.table, extra.file, sep="\t", row.names=F)
	}#end if(file.exists(annovar.csv))
}#end for (ann.sample in annotated.samples)

summary.table = data.frame(Sample=annotated.samples, exonic.count=exonic.count, 
							clinvar.count=clinvar.count,
							kaviar.gnomAD.rare.count=kaviar.gnomAD.rare.count,
							damaging.count=damaging.count, exonic.rare.damaging.count=exonic.rare.damaging.count,
							cosmic.count=cosmic.count, gwas.catalog.count=gwas.catalog.count, oreganno.count=oreganno.count)
write.table(summary.table, summary.file, sep="\t", row.names=F)
