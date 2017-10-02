annotated.folder = "../Result/Joint_GATK_Variant_Calls"
summary.file = "ANNOVAR_variant_summary.txt"
checkIDs = TRUE

#annotated.folder = "../Result/VarScan_Somatic_Variant_Calls"
#summary.file = "ANNOVAR_VarScan_Somatic_variant_summary.txt"
#checkIDs = FALSE

param.table = read.table("parameters.txt", header=T, sep="\t")
genome = as.character(param.table$Value[param.table$Parameter == "genome"])
sample.description.file = as.character(param.table$Value[param.table$Parameter == "sample_description_file"])

annotated.folders = list.dirs(annotated.folder)
annotated.folders = annotated.folders[annotated.folders != annotated.folder]

annotated.samples = gsub(annotated.folder,"",annotated.folders)
annotated.samples = gsub("/","",annotated.samples)
annotated.samples = gsub("\\\\","",annotated.samples)

meta.table = read.table(sample.description.file, head=T, sep="\t")
sample.label = meta.table$userID[match(annotated.samples,meta.table$sampleID)]
if(!checkIDs){
	sample.label=annotated.samples
}else{
	if(length(sample.label) != length(sample.label[!is.na(sample.label)])){
		print("There is an issue with mapping some samples")
		names(sample.label)=annotated.samples
		print(sample.label)
		stop()
	}
}#end else

output.samples = c()
exonic.count = c()
kaviar.gnomAD.rare.count = c()
damaging.count = c()
exonic.rare.damaging.count = c()
cosmic.count = c()
nci60.count = c()
clinvar.count = c()
gwas.catalog.count = c()
oreganno.count = c()
repeat.count = c()

root.folder = annotated.folder

for (i in 1:length(annotated.samples)){
	annotated.folder = annotated.folders[i]
	sampleID = annotated.samples[i]
	
	annovar.csv = file.path(annotated.folder, paste(sampleID,".",genome,"_multianno.csv",sep=""))
	annovar.RepeatMasker = file.path(annotated.folder, paste(sampleID,"_annovar_RepeatMasker.",genome,"_bed",sep=""))
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

		RepeatMasker.table = tryCatch({read.delim(annovar.RepeatMasker, head=F)},
									error=function(cond){
										return(matrix(NA,ncol=7))
									})
		RepeatMaskerID = as.character(RepeatMasker.table[,2])
		RepeatMaskerID = gsub("Name=","",RepeatMaskerID)
		repeat.count = c(repeat.count, length(RepeatMaskerID))
		RepeatMasker.annovarID = paste(RepeatMasker.table[,3],RepeatMasker.table[,4],RepeatMasker.table[,5],RepeatMasker.table[,6],RepeatMasker.table[,7],sep="\t")
		RepeatMaskerID = RepeatMaskerID[match(annovarID,RepeatMasker.annovarID)]
		
		gwas.table = tryCatch({read.delim(annovar.gwas, head=F)},
									error=function(cond){
										return(matrix(NA,ncol=7))
									})
		gwas.rsID = as.character(gwas.table[,2])
		gwas.rsID = gsub("Name=","",gwas.rsID)
		gwas.catalog.count = c(gwas.catalog.count, length(gwas.rsID))
		gwas.annovarID = paste(gwas.table[,3],gwas.table[,4],gwas.table[,5],gwas.table[,6],gwas.table[,7],sep="\t")
		gwas.rsID = gwas.rsID[match(annovarID,gwas.annovarID)]
		
		oreganno.table = tryCatch({read.delim(bedtools.oreganno, head=F)},
									error=function(cond){
										return(matrix(NA,ncol=7))
									})
		oregannoID = oreganno.table[,8]
		oreganno.count = c(oreganno.count, length(oregannoID))
		oreganno.annovarID = paste(oreganno.table[,1],oreganno.table[,2],oreganno.table[,3],oreganno.table[,4],oreganno.table[,5],sep="\t")
		oregannoID = oregannoID[match(annovarID,oreganno.annovarID)]
		
		extra.table = data.frame(big.table, gwas.catalog = gwas.rsID,
								oreganno = oregannoID, RepeatMasker=RepeatMaskerID,
								rare.flag, exonic.damaging.flag = damaging.flag,
								exonic.rare.damaging.flag = rare.damaging.flag)
		extra.file = paste(root.folder, "/",sample.label[i],"_combined_summary.txt",sep="")
		write.table(extra.table, extra.file, sep="\t", row.names=F)
	}#end if(file.exists(annovar.csv))
}#end for (ann.sample in annotated.samples)

summary.table = data.frame(Sample=annotated.samples, exonic.count=exonic.count, 
							clinvar.count=clinvar.count,
							kaviar.gnomAD.rare.count=kaviar.gnomAD.rare.count,
							damaging.count=damaging.count, exonic.rare.damaging.count=exonic.rare.damaging.count,
							cosmic.count=cosmic.count, oreganno.count=oreganno.count,
							gwas.catalog.count=gwas.catalog.count, repeat.count)
write.table(summary.table, summary.file, sep="\t", row.names=F)
