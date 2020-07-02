import re
import sys

prevVcf = "1000_genomes_20140502_plus_2-SNP-chip_plus_Genos-Off-Target-flank50000-ref286.vcf"
prevPed = "1000_genomes_20140502_plus_2-SNP-chip_plus_Genos-Off-Target-flank50000-ref286.ped"
newVcf = "FILTERED-1000_genomes_20140502_plus_2-SNP-chip_plus_Genos-Off-Target-flank50000-ref286.vcf"
newPed = "FILTERED-1000_genomes_20140502_plus_2-SNP-chip_plus_Genos-Off-Target-flank50000-ref286.ped"

#create hash with larger .ped file
pedHash = {}

inHandle = open(prevPed)
line = inHandle.readline()
			
while line:
	line = re.sub("\r","",line)
	line = re.sub("\n","",line)
	
	lineInfo = line.split("\t")
	sampleID = lineInfo[1]
	
	#print "|" + sampleID + "|"
	
	pedHash[sampleID]=line
	
	line = inHandle.readline()

inHandle.close()

#read .vcf and create matching .ped file
vcfHandle = open(newVcf,"w")
pedHandle = open(newPed,"w")

inHandle = open(prevVcf)
line = inHandle.readline()

keepIndex = []

while line:
	line = re.sub("\r","",line)
	line = re.sub("\n","",line)
	
	lineInfo = line.split("\t")
	CHR = lineInfo[0]
	POS = lineInfo[1]
	ID = lineInfo[2]
	REF = lineInfo[3]
	ALT = lineInfo[4]
	QUAL = lineInfo[5]
	FILTER = lineInfo[6]
	INFO = lineInfo[7]
	FORMAT = lineInfo[8]
	
	text = CHR + "\t" +  POS + "\t" + ID + "\t" + REF + "\t" + ALT + "\t" + QUAL + "\t" + FILTER + "\t" + INFO + "\t" + FORMAT
	
	if re.search("^#",line):
		lineInfo = line.split("\t")
		for i in range(9,len(lineInfo)):
			sampleID =  lineInfo[i]
			
			if sampleID in pedHash:
				pedLine = pedHash[sampleID] + "\n"
				pedHandle.write(pedLine)
				
				keepIndex.append(i)
				text = text + "\t" + sampleID
			else:
				print "Skip .ped line and .vcf column for sample ("+str(i)+"): |" + sampleID + "|"
	else:
		for i in keepIndex:
			text = text + "\t" + lineInfo[i]

	if (CHR != "X") and (CHR != "Y"):
		text = text + "\n"
		vcfHandle.write(text)
	
	line = inHandle.readline()

inHandle.close()
vcfHandle.close()
pedHandle.close()