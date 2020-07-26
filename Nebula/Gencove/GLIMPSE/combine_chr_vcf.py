import sys
import re
import os

sampleID = "lcWGS"
GLIMPSEprefix = "Nebula_down10"
individual_VCF = GLIMPSEprefix+"/GLIMPSE_imputed/CW_Nebula-down10_merged-for_CW.vcf"

outHandle = open(individual_VCF, 'w')

for x in range(1,23):
	print"Working on chromosome " + str(x)+ "... "

	inputedVCF = GLIMPSEprefix+"/GLIMPSE_imputed/chr"+str(x)+".sample.vcf"
	
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
						
						if x == 1:
							text = chr + "\t" + pos + "\t" + varID + "\t" +  ref + "\t"  +  alt + "\t" + qual + "\t" + filter + "\t" + info + "\t" + format + "\t" +sampleID+ "\n"
							outHandle.write(text)
			else:
				if sampleIndex == -1:
					print "Issue finding sample: " + sampleID
					sys.exit()
				
				#there are no quality filters to select GLIMPSE imputations with a "PASS" status
				geno_text = lineInfo[sampleIndex]
				#print line
				#print geno_text
				geno = geno_text[0:3]
				geno = re.sub("\|","/",geno)
					
				if (geno == "0/0") or (geno == "1/1") or (geno == "0/1") or (geno == "1/0"):
					text = chr + "\t" + pos + "\t" + varID + "\t" +  ref + "\t"  +  alt + "\t" + qual + "\t" + filter + "\t" + info + "\t" + format + "\t" +geno+ "\n"
					outHandle.write(text)					
				elif geno != "./.":
					print "Update code to decide whether to keep genotype: |" + geno + "|"
					sys.exit()	
			
		line = inHandle.readline()
		
	inHandle.close()

outHandle.close()