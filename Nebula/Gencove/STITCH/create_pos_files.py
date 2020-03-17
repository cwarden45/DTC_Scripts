import sys
import re
import os

inputfile = "../ALL.chip.omni_broad_sanger_combined.20140818.snps_frequencies_UNRELATED_plus_1child_PLUS_23andMe_CW.vcf"
outputfolder = "human_g1k_v37-pos_files"

command = "mkdir " + outputfolder
os.system(command)


inHandle = open(inputfile)
line = inHandle.readline()

prevChr = ""

while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	commentResult = re.search("^#",line)
	headerResult = re.search("^CHR\tPOS",line)#when working with a non-standard file
	
	if (not commentResult) and (not headerResult):
		lineInfo = line.split("\t")
		chr = lineInfo[0]
		pos = lineInfo[1]
		ref = lineInfo[3]
		var = lineInfo[4]
		
		if chr != prevChr:
			if prevChr != "":
				outHandle.close()
			prevChr = chr
			print "Creating position(pos) file for " + chr + "...\n";
			
			outputfile = outputfolder + "/" + chr + "_pos.txt"
			outHandle = open(outputfile, 'w')
			
		text = chr +"\t" + pos + "\t" + ref + "\t" + var + "\n"
		outHandle.write(text)
		
	line = inHandle.readline()
	
inHandle.close()
outHandle.close()