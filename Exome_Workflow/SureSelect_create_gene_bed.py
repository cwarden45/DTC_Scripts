import sys
import re
import os

target_bed = "S04380110_V5/S04380110_Covered.bed"
target_bed_v2 = "S04380110_V5/S04380110_Covered_ref_symbol.bed"
gene_bed = "S04380110_V5/ref_symbol.bed"
intron_bed = "S04380110_V5/target_spacer_by_symbol.bed"

chrHash = {}
startHash = {}
stopHash = {}

outHandle = open(target_bed_v2, "w")

inHandle = open(target_bed)
line = inHandle.readline()

while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	chrResult = re.search("^chr",line)
	
	if chrResult:
		lineInfo = line.split("\t")
		chr = lineInfo[0]
		start = int(lineInfo[1])
		stop = int(lineInfo[2])
		ann = lineInfo[3]
		
		refResult = re.search("^ref\|",ann)
		
		if refResult:
			annInfo = ann.split(",")
			gene = re.sub("^ref\|","",annInfo[0])
			
			if gene in startHash:
				if (start < startHash[gene]) and (chr == chrHash[gene]):
					startHash[gene]=start
			else:
				startHash[gene]=start
				chrHash[gene] = chr

			if gene in stopHash:
				if (stop > stopHash[gene]) and (chr == chrHash[gene]):
					stopHash[gene]=stop
			else:
				stopHash[gene]=stop
				chrHash[gene] = chr

	
			text = chr + "\t" + str(start) + "\t" + str(stop) + "\t" + gene + "\n"
			outHandle.write(text)
				
	line = inHandle.readline()
inHandle.close()
outHandle.close()

outHandle = open(gene_bed, "w")

for gene in chrHash:
	chr = chrHash[gene]
	start = startHash[gene]
	stop = stopHash[gene]
	
	text = chr + "\t" + str(start) + "\t" + str(stop) + "\t" + gene + "\n"
	outHandle.write(text)

outHandle.close()

#use `bedtools subtract` for introns
command = "/opt/bedtools2/bin/bedtools subtract -a " +gene_bed + " -b " +  target_bed_v2 + " > " + intron_bed
os.system(command)