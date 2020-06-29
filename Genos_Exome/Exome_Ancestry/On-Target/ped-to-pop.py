import re
import sys

ped_file = "../../../Mayo_GeneGuide/plink_IBD_Genetic_Distance/1000_genomes_20140502_plus_2-SNP-chip_plus_Mayo-Exome_plus_Genos-BWA-MEM-Exome_plus_Veritas_WGS.ped"
pop_file = "../../../Mayo_GeneGuide/plink_IBD_Genetic_Distance/1000_genomes_20140502_plus_2-SNP-chip_plus_Mayo-Exome_plus_Genos-BWA-MEM-Exome_plus_Veritas_WGS.pop"

#from ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20140502_sample_summary_info/
family_mapping = "../../../23andMe/1000_Genomes/20140502_all_samples.ped";

#from https://github.com/cwarden45/QCarray_Ethnicity (from http://www.internationalgenome.org/category/population/)
super_pop_mapping = "../../../23andMe/1000_Genomes/super-pop_mapping_for_Ogembo_QCarray_plus_CHD.txt";

#population hash
popHash = {}

inHandle = open(family_mapping)
line = inHandle.readline()
			
while line:
	line = re.sub("\r","",line)
	line = re.sub("\n","",line)
	
	lineInfo = line.split("\t")
	sampleID = lineInfo[1]
	pop = lineInfo[6]
	
	popHash[sampleID]=pop
	
	line = inHandle.readline()

inHandle.close()

#super-population hash
superPopHash = {}

inHandle = open(super_pop_mapping)
line = inHandle.readline()
			
while line:
	line = re.sub("\r","",line)
	line = re.sub("\n","",line)
	
	lineInfo = line.split("\t")
	pop = lineInfo[0]
	superPop = lineInfo[1]
	
	superPopHash[pop]=superPop
	
	line = inHandle.readline()

inHandle.close()

#create .pop file

outHandle = open(pop_file,"w")

inHandle = open(ped_file)
line = inHandle.readline()
			
while line:
	line = re.sub("\r","",line)
	line = re.sub("\n","",line)
	
	lineInfo = line.split("\t")
	sampleID = lineInfo[1]
	
	if sampleID in popHash:
		pop = popHash[sampleID]
		
		if pop in superPopHash:
			superPop = superPopHash[pop]
			text = superPop + "\n"
			outHandle.write(text)
		else:
			print "Issue mapping population for :" + pop
			sys.exit()
	else:
		print "Assume " + sampleID + " is a test sample!"
		text = "-\n"
		outHandle.write(text)
	
	line = inHandle.readline()

inHandle.close()
outHandle.close()