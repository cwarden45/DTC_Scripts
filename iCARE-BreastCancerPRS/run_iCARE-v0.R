#setwd("E:\\WGS_Exome_Analysis\\My_Veritas_WGS\\iCARE-BreastCancerPRS")

#https://dceg.cancer.gov/tools/analysis/icare
#https://www.bioconductor.org/packages/release/bioc/html/iCARE.html

###########################################################################################
### IMPORTANT: I am assuming:															###
###           -Everything is for hg19													###
###			  -I can use the Genes for Good VCF to define reference and variant alleles ###
###			  -I can use the 23andMe VCF to chromosome and position                     ###
###########################################################################################

Geno23 = "../23andMe/genome_Charles_Warden_v3_v5_Full_20190711213724.txt"
GenoGFG = "../Genes_for_Good/GFG_filtered_unphased_genotypes.vcf"
GenoVeritas = "../K33YDXX.vcf"
output.plot = "risk_density-v0.png"

library("iCARE")

CW.genos = matrix(ncol=ncol(new_snp_prof), nrow=4)
colnames(CW.genos) = names(new_snp_prof)
rownames(CW.genos) = c("23andMe","Genes for Good", "Veritas WGS (VCF)", "Veritas WGS (alt)")

#Try to create a new `new_snp_prof` with data from myself (otherwise following example Example1.B)

GenoGFG.table = read.table(GenoGFG, head=F, sep="\t")
GenoGFG.paired = GenoGFG.table[match(names(new_snp_prof),GenoGFG.table$V3),]
GenoGFG.geno = as.character(GenoGFG.paired$V10)
GenoGFG.geno[GenoGFG.geno == "0/0"]=0
GenoGFG.geno[GenoGFG.geno == "0/1"]=1
GenoGFG.geno[GenoGFG.geno == "1/1"]=2
GenoGFG.geno = as.numeric(GenoGFG.geno)
CW.genos[2,]= GenoGFG.geno

##Supplemental data from https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0228198#sec027
#PLOS.supp = load("bc_data.rda")

master.id = names(new_snp_prof)
master.ref = GenoGFG.paired$V4
master.var = GenoGFG.paired$V5
print(master.id[is.na(master.ref)])
#rs12405132 - hg19:chr1:NC_000001.10:g.145644984C>T
master.ref[(1:length(master.id))[master.id == "rs12405132"]]="C"
master.var[(1:length(master.id))[master.id == "rs12405132"]]="T"
#rs12048493 - hg19:chr1:NC_000001.10:g.149927034A>C
master.ref[(1:length(master.id))[master.id == "rs12048493"]]="A"
master.var[(1:length(master.id))[master.id == "rs12048493"]]="C"
#rs4245739 - hg19:?
#rs72755295 - hg19:chr1:NC_000001.10:g.242034263A>G
master.ref[(1:length(master.id))[master.id == "rs72755295"]]="A"
master.var[(1:length(master.id))[master.id == "rs72755295"]]="G"
#rs12710696 - hg19:?
#rs6796502 - hg19:?
#rs13162653 - hg19:?
#rs2012709 - hg19:chr5:NC_000005.9:g.32567732C>T
master.ref[(1:length(master.id))[master.id == "rs2012709"]]="C"
master.var[(1:length(master.id))[master.id == "rs2012709"]]="T"
#rs7707921 - hg19:?
#rs9257408 - hg19:?
#rs4593472 - hg19:chr7:NC_000007.13:g.130667121C>T
master.ref[(1:length(master.id))[master.id == "rs4593472"]]="C"
master.var[(1:length(master.id))[master.id == "rs4593472"]]="T"
#rs9693444 - hg19:?
#rs13365225 - hg19:?
#rs13267382 - hg19:chr8:NC_000008.10:g.117209548A>G
master.ref[(1:length(master.id))[master.id == "rs13267382"]]="A"
master.var[(1:length(master.id))[master.id == "rs13267382"]]="G"
#rs11780156 - hg19:chr8:NC_000008.10:g.129194641C>T
master.ref[(1:length(master.id))[master.id == "rs11780156"]]="C"
master.var[(1:length(master.id))[master.id == "rs11780156"]]="T"
#rs554219 - hg19:?
#rs75915166 - hg19:chr11:NC_000011.9:g.69379161C>A
master.ref[(1:length(master.id))[master.id == "rs75915166"]]="C"
master.var[(1:length(master.id))[master.id == "rs75915166"]]="A"
#rs11627032 - hg19:?
#rs146699004 --> rs10612648 - hg19:?
#rs745570 - hg19:chr17:NC_000017.10:g.77781725A>G
master.ref[(1:length(master.id))[master.id == "rs745570"]]="A"
master.var[(1:length(master.id))[master.id == "rs745570"]]="G"
#rs6507583 - hg19:?
#rs4808801 - hg19:chr19:NC_000019.9:g.18571141A>G
master.ref[(1:length(master.id))[master.id == "rs4808801"]]="A"
master.var[(1:length(master.id))[master.id == "rs4808801"]]="G"
#rs2284378 - hg19:?

Geno23.table = read.table(Geno23, head=F, sep="\t")
Geno23.paired = Geno23.table[match(names(new_snp_prof),Geno23.table$V1),]
for (i in 1:nrow(Geno23.paired)){
	if(!(is.na(Geno23.paired$V4[i]))&&(Geno23.paired$V4[i] != "--")){
		if(!(is.na(master.ref[i]))){
			temp.geno1=substr(Geno23.paired$V4[i],1,1)
			temp.geno2=substr(Geno23.paired$V4[i],2,2)
			
			temp.geno.count = 0
			if(temp.geno1 == master.var[i]){
				temp.geno.count = temp.geno.count + 1
			}#end if(temp.geno1 == master.var[i])

			if(temp.geno2 == master.var[i]){
				temp.geno.count = temp.geno.count + 1
			}#end if(temp.geno2 == master.var[i])
			
			CW.genos[1,i]=temp.geno.count
		}#end if(!(is.na(master.ref[i])))
	}#end if(!(is.na(Geno23.paired$V4))&&(Geno23.paired != "--"))
}#end for (i in 1:nrow(Geno23.paired))

master.chr = paste("chr",Geno23.paired$V2,sep="")
master.pos = Geno23.paired$V3

###NOTE: This file takes longer to load.  However, it was still within minutes for a PC with 8 GB of RAM and 4 CPUs).
GenoVeritas.table = read.table(GenoVeritas, head=F, sep="\t")
print(dim(GenoVeritas.table))
GenoVeritas.table = GenoVeritas.table[GenoVeritas.table$V7 == "PASS",]
print(dim(GenoVeritas.table))

WGS.VCF_ID = paste(GenoVeritas.table$V1,GenoVeritas.table$V2,GenoVeritas.table$V4,GenoVeritas.table$V5)
master.VCF_ID = paste(master.chr,master.pos,master.ref,master.var)

GenoVeritas.paired = GenoVeritas.table[match(master.VCF_ID,WGS.VCF_ID),]
##NOTE a gVCF might have been preferable, if confident **matches** to the reference were defined.
for (i in 1:nrow(GenoVeritas.paired)){
	if(!is.na(GenoVeritas.paired$V10[i])){
		temp.geno = substr(GenoVeritas.paired$V10[i],1,3)
		
		if(temp.geno == "0/0"){
			CW.genos[3,i]=0
		}else if(temp.geno == "0/1"){
			CW.genos[3,i]=1
		}else if(temp.geno == "1/1"){
			CW.genos[3,i]=2
		}else{
			print(paste("Define way to parse :",temp.geno,sep=""))
		}#end else
	}#end if(!is.na(GenoVeritas.paired$V10[i]))
}#end for (i in 1:nrow(GenoVeritas.paired))

temp.WGS.geno = CW.genos[3,]
temp.WGS.geno[!(is.na(master.ref))&is.na(temp.WGS.geno)]=0
CW.genos[4,]=temp.WGS.geno
#I noticed that accidentially calling all mapped positions "0" caused the estimated risk to be low.  So, I assume all variants are enriched (to some extent) in cases.

#estimated risk for ages 50-80 (Example 1.B)
#use `CW.genos` instead of `new_snp_prof`
res_snps_dat = computeAbsoluteRisk(model.snp.info = bc_72_snps,
								model.disease.incidence.rates = bc_inc,
								model.competing.incidence.rates = mort_inc,
								apply.age.start = 50,
								apply.age.interval.length = 30,
								apply.snp.profile = CW.genos,
								return.refs.risk =TRUE)

png(output.plot)
plot(density(res_snps_dat$refs.risk),
		lwd=2,
		main="iCARE SNP-only Risk Estimate: Ages 50-80",
		xlab="Absolute Risk of Breast Cancer")
abline(v=res_snps_dat$risk[1], col="red")
abline(v=res_snps_dat$risk[2], col="orange")
abline(v=res_snps_dat$risk[3], col="gray")
abline(v=res_snps_dat$risk[4], col="blue")
legend("topleft",
			legend=rownames(CW.genos),
			col=c("red","orange","gray","blue"),
			lwd=1)
dev.off()