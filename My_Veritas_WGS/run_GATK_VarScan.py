import sys
import re
import os
import csv

bam= "veritas_wgs.filter.rg.bam"
ref = "hg19.fasta"
javaMem = "4g"
gatkFlag="1"
varscanFlag = "1"

for arg in sys.argv:
	bamResult = re.search("^--bam=(.*)",arg)
	refResult = re.search("^--ref=(.*)",arg)
	memResult = re.search("^--mem=(.*)",arg)
	gatkResult = re.search("^--gatk=(.*)",arg)
	varscanResult = re.search("^--varscan=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if bamResult:
		bam = bamResult.group(1)

	if refResult:
		ref = refResult.group(1)
		
	if memResult:
		javaMem = memResult.group(1)

	if gatkResult:
		gatkFlag = gatkResult.group(1)
		
	if varscanResult:
		varscanFlag = varscanResult.group(1)
		
	if helpResult:
		print "Usage: python run_GATK_VarScan.py --bam=veritas_wgs.filter.rg.bam --ref=hg19.fasta --mem=4g\n"
		print "--bam : Sorted .bam file with read groups (and duplicates removed)\n"
		print "--ref : FASTA reference\n"
		print "--mem : Memory to be used by GATK, VarScan, and Picard\n"
		print "--gatk : Run GATK? (1=yes, 0=no)\n"
		print "--varscan : Run GATK? (1=yes, 0=no)\n"
		sys.exit()

if varscanFlag == "1":
	print "Creating .pileup file for VarScan"
	nodupPileup = re.sub(".bam$",".pileup",bam)
	command = "/opt/samtools-1.3/samtools mpileup -C50 -f " + ref + " " + bam + " > " + nodupPileup
	#os.system(command)
	
	minCoverage = 10
	minVarReads = 4
	minQual = 20
	minFreq = 0.3
	
	print "Defining VarScan SNPs"
	nodupVarScanSNP = re.sub(".bam$",".varscan.snp.vcf",bam)
	command = "java -jar -Xmx" +javaMem+ " /opt/VarScan.v2.4.2.jar mpileup2snp "+nodupPileup+" --min-coverage "+str(minCoverage)+" --min-reads2 "+str(minVarReads)+" --min-avg-qual "+str(minQual)+" --min-var-freq "+str(minFreq)+" --output-vcf > " + nodupVarScanSNP
	#os.system(command)

	print "Defining VarScan Indels"
	nodupVarScanSNP = re.sub(".bam$",".varscan.indel.vcf",bam)
	command = "java -jar -Xmx" +javaMem+ " /opt/VarScan.v2.4.2.jar mpileup2indel "+nodupPileup+" --min-coverage "+str(minCoverage)+" --min-reads2 "+str(minVarReads)+" --min-avg-qual "+str(minQual)+" --min-var-freq "+str(minFreq)+" --output-vcf > " + nodupVarScanSNP
	os.system(command)
	
if gatkFlag == "1":
	refSearch1 = re.search(".fasta$",ref)
	refSearch2 = re.search(".fa$",ref)

	if refSearch1:
		refDict = 	re.sub(".fasta$",".dict",ref)
	elif refSearch2:
		refDict = 	re.sub(".fa$",".dict",ref)
	else:
		print "Reference needs to end with .fasta or .fa: " + ref
		sys.exit()

	if not os.path.isfile(refDict):
		print "Creating Sequence Dict for GATK"
		command = "java -jar -Xmx" +javaMem+ " /opt/picard-tools-2.5.0/picard.jar CreateSequenceDictionary R=" + ref + " O=" + refDict
		#os.system(command)

	print "Call SNPs and Indels using GATK HaplotypeCaller"
	nodupGATKvcf = re.sub(".bam$",".GATK.HC.vaf",bam)
	command = "java -jar -Xmx" +javaMem+ " /opt/GenomeAnalysisTK.jar -T HaplotypeCaller -R "+ ref +" -I "+bam+" -o " + nodupGATKvcf
	os.system(command)
