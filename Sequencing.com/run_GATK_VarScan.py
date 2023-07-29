import sys
import re
import os

bam= "BWA_MEM.nodup.bam"
ref = "/home/cwarden/Ref/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa"
javaMem = "4g"
gatkFlag="1"
varscanFlag = "1"

#GATK dict file
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
	command = "java -jar -Xmx" +javaMem+ " /opt/picard-v2.21.9.jar CreateSequenceDictionary R=" + ref + " O=" + refDict
	os.system(command)

#run VarScan
if varscanFlag == "1":
	print "Creating .pileup file for VarScan"
	nodupPileup = re.sub(".bam$",".pileup",bam)
	command = "/opt/samtools/samtools mpileup -C50 -f " + ref + " " + bam + " > " + nodupPileup
	os.system(command)
	
	minCoverage = 10
	minVarReads = 4
	minQual = 20
	minFreq = 0.3
	
	print "Defining VarScan SNPs"
	nodupVarScanSNP = re.sub(".bam$",".varscan.snp.vcf",bam)
	command = "java -jar -Xmx" +javaMem+ " /opt/VarScan.v2.4.6.jar mpileup2snp "+nodupPileup+" --min-coverage "+str(minCoverage)+" --min-reads2 "+str(minVarReads)+" --min-avg-qual "+str(minQual)+" --min-var-freq "+str(minFreq)+" --output-vcf > " + nodupVarScanSNP
	os.system(command)

	print "Defining VarScan Indels"
	nodupVarScanSNP = re.sub(".bam$",".varscan.indel.vcf",bam)
	command = "java -jar -Xmx" +javaMem+ " /opt/VarScan.v2.4.6.jar mpileup2indel "+nodupPileup+" --min-coverage "+str(minCoverage)+" --min-reads2 "+str(minVarReads)+" --min-avg-qual "+str(minQual)+" --min-var-freq "+str(minFreq)+" --output-vcf > " + nodupVarScanSNP
	os.system(command)

	command = "rm " +nodupPileup
	os.system(command)
	
if gatkFlag == "1":
	print "Call SNPs and Indels using GATK HaplotypeCaller"
	nodupGATKvcf = re.sub(".bam$",".GATK.HC.vcf",bam)
	#previous code used GATK3, but current code uses GATK4
	command = "/opt/gatk-4.1.4.1/gatk --java-options '-Xmx" +javaMem+ "' HaplotypeCaller  --reference "+ ref +" --input "+bam+" --output " + nodupGATKvcf
	os.system(command)
	
	nodupGATKvcf = re.sub(".bam$",".GATK.HC.nosoftclip.vcf",os.path.basename(bam))
	command = "/opt/gatk-4.0.1.1/gatk --java-options '-Xmx" +javaMem+ "' HaplotypeCaller --reference "+ ref +" --input "+bam+" --output " + nodupGATKvcf + " --dont-use-soft-clipped-bases true"
	os.system(command)
	
	filteredGATKvcf = re.sub(".bam$",".GATK.HC.nosoftclip.filtered.vcf",os.path.basename(bam))
	command = "/opt/gatk-4.0.1.1/gatk --java-options '-Xmx" +javaMem+ "' VariantFiltration --variant "+nodupGATKvcf+" --output " + filteredGATKvcf + " -window 35 -cluster 3 -filter-name QD -filter \"QD < 2.0\" -filter-name FS -filter \"FS > 30.0\""
	os.system(command)