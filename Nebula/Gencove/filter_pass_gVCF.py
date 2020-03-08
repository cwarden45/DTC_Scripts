import sys
import re
import os

inputfile = "Gencove_basepaws-cat_downsample_50x_impute-vcf.vcf"

outputfile = re.sub(".vcf$","-PASS.vcf",inputfile)

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
			
			if filter == "PASS":
				text = line + "\n"
				outHandle.write(text)
		
	line = inHandle.readline()
	
inHandle.close()
outHandle.close()