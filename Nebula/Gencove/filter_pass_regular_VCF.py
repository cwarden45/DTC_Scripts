import sys
import re
import os

#inputfile = "Gencove_basepaws-cat_downsample_50x_impute-vcf.vcf"
#inputfile = "Gencove_basepaws-cat_downsample_100x_impute-vcf.vcf"

#inputfile = "Gencove_Nebula-human_downsample_2x_impute-vcf.vcf"
inputfile = "Gencove_Nebula-human_provided_impute-vcf.vcf"

outputfile = re.sub(".vcf$","-PASS-VAR.vcf",inputfile)

print outputfile

outHandle = open(outputfile, 'w')

inHandle = open(inputfile)
line = inHandle.readline()
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	
	commentResult = re.search("^##",line)
	
	if not commentResult:
		headerResult = re.search("^#",line)
		
		if headerResult:
			text = line + "\n"
			outHandle.write(text)
		else:
			filter = lineInfo[6]
			genoText = lineInfo[9]
			geno = genoText[0:3]
			
			if (filter == "PASS") and ((geno == "0/1") or (geno == "1/1")):
				text = line + "\n"
				outHandle.write(text)
		
	line = inHandle.readline()
	
inHandle.close()
outHandle.close()