sampleID = "23andMe"
plinkPrefix = "../SNP2HLA/23andMe"

#sampleID = "G4G"
#plinkPrefix = "../SNP2HLA/G4G"

library("HIBAG")

#assumes that plink formated file has been created from 23andMe file (using SNP2HLA code)
mygeno =  hlaBED2Geno(bed.fn=paste(plinkPrefix,".bed",sep=""),
						fam.fn=paste(plinkPrefix,".fam",sep=""),
						bim.fn=paste(plinkPrefix,".bim",sep=""))
summary(mygeno)

#Download European model from http://www.biostat.washington.edu/~bsweir/HIBAG/ (Asian, Hispanic, and African ancestry models also available)
model.list = get(load("European-HLA4-hg19.RData"))

HLA.types = c("A","B","C","DRB1","DQA1","DQB1")
#can also use names(model.list)

allele1 = c()
allele2 = c()
prob = c()

for (i in 1:length(HLA.types)){
	HLA=HLA.types[i]
	print(HLA)
	
	model <- hlaModelFromObj(model.list[[HLA]])
	
	HLA.pred = predict(model, mygeno, type="response+prob")
	summary(HLA.pred)
	
	allele1[i] = HLA.pred$value$allele1
	allele2[i] = HLA.pred$value$allele2
	prob[i] = HLA.pred$value$prob
}#end for (HLA in HLA.types)

output.table = data.frame(HLA.types, allele1, allele2, prob)
output.file = paste(sampleID,"_HIBAG_HLA.txt",sep="")
write.table(output.table, output.file, row.names=F, sep="\t", quote=F)