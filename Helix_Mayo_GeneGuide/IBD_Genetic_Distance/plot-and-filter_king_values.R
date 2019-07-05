##family IDs didn't get carried over from .ped file, but this will be OK for a few samples
#new.sampleIDs =  c("GFG","CW23")
#K1G.ped.ref =  "../RFMix_Ancestry/20140502_all_samples.ped"
#input.king =  "1000_genomes_20140502_plus_2-SNP-chip.kin0"
#output.prefix = "plink_kinship_2-SNP-chip"

#family IDs didn't get carried over from .ped file, but this will be OK for a few samples
new.sampleIDs =  c("GFG","CW23","Mayo")
K1G.ped.ref =  "../RFMix_Ancestry/20140502_all_samples.ped"
input.king =  "1000_genomes_20140502_plus_2-SNP-chip_plus_Mayo-Exome.kin0"
output.prefix = "plink_kinship_2-SNP-chip_plus_Mayo-GeneGuide"


kin.table = read.table(input.king, head=F, sep="\t")
names(kin.table) = c("FAM1","ID1","FAM2","ID2","nsnp","hethet","ibs0","kinship")

##for de-bugging
#kin.table=kin.table[1:100000,]

ped.table = read.table(K1G.ped.ref, head=T, sep="\t")

small.table = kin.table[(kin.table$ID1 %in% new.sampleIDs)&(kin.table$ID2 %in% new.sampleIDs),]
output.table = paste(output.prefix,"_stats.txt",sep="")
write.table(small.table, output.table, quote=F, sep="\t", row.names=F)

relationship.category = rep(NA,nrow(kin.table))
relationship.category[(kin.table$ID1 %in% new.sampleIDs)&(kin.table$ID2 %in% new.sampleIDs)] = "New"

for (i in 1:nrow(kin.table)){
	sample1 = as.character(kin.table$ID1[i])
	sample2 = as.character(kin.table$ID2[i])
	
	if((sample1 %in% ped.table$Individual.ID)&(sample2 %in% ped.table$Individual.ID)){

		info1 =  ped.table[as.character(ped.table$Individual.ID) == sample1,]
		info2 =  ped.table[as.character(ped.table$Individual.ID) == sample2,]
		
		if (info1$Family.ID != info2$Family.ID){
			relationship.category[i]="1000 Genomes (Different Families)"
		}else{
			if(as.character(info1$Paternal.ID) == sample2){
				#Father
				relationship.category[i]="1000 Genomes Parent-to-Child"
			}else if(as.character(info2$Paternal.ID) == sample1){
				#Father
				relationship.category[i]="1000 Genomes Parent-to-Child"
			}else if(as.character(info1$Maternal.ID) == sample2){
				#Mother
				relationship.category[i]="1000 Genomes Parent-to-Child"
			}else if(as.character(info1$Maternal.ID) == sample2){
				#Mother
				relationship.category[i]="1000 Genomes Parent-to-Child"
			}else
			
			#siblings
			if((info1$Siblings != 0)&(info2$Siblings != 0)){
				sibling.list1 = unlist(strsplit(as.character(info1$Siblings),split=","))
				sibling.list2 = unlist(strsplit(as.character(info2$Siblings),split=","))
				
				for (j in 1:length(sibling.list1)){
					if(as.character(sibling.list1[j]) == sample2){
						relationship.category[i]="1000 Genomes Siblings"
					}
				}#end for (j in 1:length(sibling.list1))
				
				for (j in 1:length(sibling.list2)){
					if(as.character(sibling.list2[j]) == sample1){
						relationship.category[i]="1000 Genomes Siblings"
					}
				}#end for (j in 1:length(sibling.list1))
			}#end if((info1$Siblings != 0)&(info2$Siblings != 0))
			
			#2nd order
			if((info1$Second.Order != 0)&(info2$Second.Order != 0)){
				rels.list1 = unlist(strsplit(as.character(info1$Second.Order),split=","))
				rels.list2 = unlist(strsplit(as.character(info2$Second.Order),split=","))
				
				for (j in 1:length(rels.list1)){
					if(as.character(rels.list1[j]) == sample2){
						relationship.category[i]="1000 Genomes 2nd Order"
					}
				}#end for (j in 1:length(rels.list1))
				
				for (j in 1:length(rels.list2)){
					if(as.character(rels.list2[j]) == sample1){
						relationship.category[i]="1000 Genomes 2nd Order"
					}
				}#end for (j in 1:length(rels.list1))
			}#end if((info1$Second.Order != 0)&(info2$Second.Order != 0))
			
			#3rd order
			if((info1$Third.Order != 0)&(info2$Third.Order != 0)){
				rels.list1 = unlist(strsplit(as.character(info1$Third.Order),split=","))
				rels.list2 = unlist(strsplit(as.character(info2$Third.Order),split=","))
				
				for (j in 1:length(rels.list1)){
					if(as.character(rels.list1[j]) == sample2){
						relationship.category[i]="1000 Genomes 3rd Order"
					}
				}#end for (j in 1:length(rels.list1))
				
				for (j in 1:length(rels.list2)){
					if(as.character(rels.list2[j]) == sample1){
						relationship.category[i]="1000 Genomes 3rd Order"
					}
				}#end for (j in 1:length(rels.list1))
			}#end if((info1$Second.Order != 0)&(info2$Second.Order != 0))
		}#end else
	}#end if((sample1 %in% ped.table$Individual.ID)&(sample2 %in% ped.table$Individual.ID))

}#end for (i in 1:nrow(kin.table))

print(table(relationship.category))

barplot.file = paste(output.prefix,".png",sep="")

kin.table = kin.table[!is.na(relationship.category),]
relationship.category = relationship.category[!is.na(relationship.category)]

#relationship.category = factor(relationship.category,
#								levels = c("1000 Genomes (Different Families)","1000 Genomes 3rd Order","1000 Genomes 2nd Order","1000 Genomes Parent-to-Child","1000 Genomes Siblings","New"))

relationship.category = factor(relationship.category,
								levels = c("1000 Genomes (Different Families)","1000 Genomes Parent-to-Child","1000 Genomes Siblings","New"))


#require(graphics)
png(barplot.file)
par(mar=c(15,5,3,2))
plot(relationship.category, kin.table$kinship, col="gray40",
	ylab="plink kinship estimate", las=2, ylim=c(-0.6,0.6))
points(jitter(as.numeric(relationship.category)), kin.table$kinship, pch=16, col=rgb(red=0.5,blue=.5,green=.5,alpha=0.05))
dev.off()