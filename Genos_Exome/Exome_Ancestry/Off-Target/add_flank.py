import re
import sys

#bed_in = "../RefSeq_genes_CDS.bed"
#bed_out = "../RefSeq_genes_CDS-flank_2000.bed"
#flank = 2000

#bed_in = "../RefSeq_genes_CDS.bed"
#bed_out = "../RefSeq_genes_CDS-flank_10000.bed"
#flank = 10000

bed_in = "../RefSeq_genes_CDS.bed"
bed_out = "../RefSeq_genes_CDS-flank_50000.bed"
flank = 50000

outHandle = open(bed_out,"w")

inHandle = open(bed_in)
line = inHandle.readline()
			
while line:
	line = re.sub("\r","",line)
	line = re.sub("\n","",line)
	
	line_info = line.split("\t")
	chr = line_info[0]
	start = int(line_info[1]) - flank
	end = int(line_info[2])	+ flank
	
	if start <1:
		start = 1
	
	text = chr + "\t" + str(start) + "\t" + str(end) + "\n"
	outHandle.write(text)
	
	line = inHandle.readline()

inHandle.close()
outHandle.close()