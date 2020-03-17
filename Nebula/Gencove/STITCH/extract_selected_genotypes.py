import sys
import re
import os

sampleID = "CW_Nebula-provided"
STITCHprefix = "STITCH-all_bam-Nebula_provided"
individual_VCF = "all-bam_merged-for_CW.vcf"

#create hash for chromosome sizes
chr_index = "Ref/human_g1k_v37.fasta.fai"

chrHash = {}

inHandle = open(chr_index)
line = inHandle.readline()

while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	lineInfo = line.split("\t")
	chr = lineInfo[0]
	size = lineInfo[1]
	
	chrHash[chr]=size
		
	line = inHandle.readline()
	
inHandle.close()

#extract imputed genotypes

outHandle = open(individual_VCF, 'w')

for x in range(1,23):
	print"Working on chromosome " + str(x)+ "... "
	output_folder = STITCHprefix+"_"+str(x)
	chrSize = chrHash[str(x)]
	#print x
	#print chrSize
	
	inputedVCF = output_folder + "/stitch."+str(x)+".1."+str(chrSize)+".vcf"
	if not os.path.isfile(inputedVCF):
		print "Creating uncompressed STITCH .vcf file"
		command = "gunzip -c " + inputedVCF+ ".gz > " +  inputedVCF
		os.system(command)
	
	sampleIndex = -1

	inHandle = open(inputedVCF)
	line = inHandle.readline()

	while line:
		line = re.sub("\n","",line)
		line = re.sub("\r","",line)
		
		commentResult = re.search("^##",line)
		
		if not commentResult:		
			lineInfo = line.split("\t")
			chr =  lineInfo[0]
			pos =  lineInfo[1]
			varID =  lineInfo[2]
			ref =  lineInfo[3]
			alt =  lineInfo[4]
			qual =  lineInfo[5]
			filter =  lineInfo[6]
			info =  lineInfo[7]
			format =  lineInfo[8]
			
			headerResult = re.search("^#",line)
			
			if headerResult:
				for i in range(0,len(lineInfo)):
					testValue = lineInfo[i]
					if testValue == sampleID:
						sampleIndex = i
						
						text = chr + "\t" + pos + "\t" + varID + "\t" +  ref + "\t"  +  alt + "\t" + qual + "\t" + filter + "\t" + info + "\t" + format + "\t" +sampleID+ "\n"
						outHandle.write(text)
			else:
				if sampleIndex == -1:
					print "Issue finding sample: " + sampleID
					sys.exit()
					
				if filter == "PASS":
					geno_text = lineInfo[sampleIndex]
					#print line
					#print geno_text
					geno = geno_text[0:3]
					
					if (geno == "0/0") or (geno == "1/1") or (geno == "0/1") or (geno == "1/0"):
						text = chr + "\t" + pos + "\t" + varID + "\t" +  ref + "\t"  +  alt + "\t" + qual + "\t" + filter + "\t" + info + "\t" + format + "\t" +geno+ "\n"
						outHandle.write(text)					
					elif geno != "./.":
						print "Update code to decide whether to keep genotype: |" + geno + "|"
						sys.exit()	
			
		line = inHandle.readline()
		
	inHandle.close()

outHandle.close()