import sys
import re
import os

filteredBam = "veritas_wgs.filter.bam"
ref = "hg19.fasta"
mantaDir = "manta"
threads = 2
mem = 5

command = "mkdir " + mantaDir
os.system(command)

command = "samtools faidx "+ref
os.system(command)

command = "/opt/manta-1.0.0.release_src/install/bin/configManta.py --bam "+filteredBam+" --referenceFasta "+ref+" --runDir " + mantaDir
os.system(command)

#you might have to re-run this command for WGS data
#not sure how starting from an intermediate step affects results...
command = mantaDir+"/runWorkflow.py -m local -j " + str(threads) + " -g " + str(mem)
os.system(command)

gzVCF = mantaDir + "/results/variants/candidateSmallIndels.vcf.gz"
command = "gunzip " + gzVCF
os.system(command)

gzVCF = mantaDir + "/results/variants/candidateSV.vcf.gz"
command = "gunzip " + gzVCF
os.system(command)

gzVCF = mantaDir + "/results/variants/diploidSV.vcf.gz"
command = "gunzip " + gzVCF
os.system(command)

#create deletion BED
#if you get an error after this point, you'll want to comment out earlier commands
mantraVCF = re.sub(".gz$","",gzVCF)
deletionBed = "Manta_DEL.bed"
filterOutHandle = open(deletionBed, 'w')

inHandle = open(mantraVCF)
line = inHandle.readline()
			
totalReads = ""
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	commentResult = re.search("^#", line)
	
	if not commentResult:
		chr = lineInfo[0]
		start = lineInfo[1]
		varID = lineInfo[2]
		type = lineInfo[4]
		varText = lineInfo[7]
		genoLeg = lineInfo[8]
		genoText = lineInfo[9]
	
		if type == "<DEL>":
			endResult = re.search("END=(\d+);", varText)
			stop = endResult.group(1)
			
			SR = 0
			PR = 0
			
			genoLegInfo = genoLeg.split(":")
			genoTextInfo = genoText.split(":")
			
			for i in xrange(0,len(genoLegInfo)):
				id = genoLegInfo[i]
				value = genoTextInfo[i]
				
				srResult = re.search("SR",id)
				prResult = re.search("PR",id)
				
				#actually, all chromosomes assumed to be diploid
				chrPloidy = 2
				varIndex = chrPloidy - 1
				
				if srResult:
					covVal = value.split(",")
					
					if(len(covVal) == chrPloidy):
						SR = int(covVal[varIndex])
					else:
						print "Need to revise SR code for " + line
						print id
						print value
						sys.exit()
			
				if prResult:
					covVal = value.split(",")
					if(len(covVal) == chrPloidy):
						PR = int(covVal[varIndex])
					else:
						print "Need to revise PR code for " + line
						print id
						print value
						sys.exit()
			
			supportingReads = SR + PR
			
			text = chr + "\t" + str(start) + "\t" + str(stop) + "\t" + varID + "\t" + str(supportingReads) + "\n"
			filterOutHandle.write(text)			

	line = inHandle.readline()	