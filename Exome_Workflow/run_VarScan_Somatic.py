import sys
import re
import os

pairingFile = "tumor_pairs.txt"

ref="/isi-dcnl/user_data/Seq/Ref/BWA/hg19.fa"
varscan_jar = "/isi-dcnl/user_data/Seq/VarScan.v2.4.3.jar"
java_mem = "16g"

inHandle = open(pairingFile)
lines = inHandle.readlines()

lineCount = 0

for line in lines:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineCount = lineCount + 1
	
	if lineCount > 1:
		lineInfo = line.split("\t")
		varscanPrefix = lineInfo[0]
		tumorBam = lineInfo[1]
		normalBam = lineInfo[2]
			
		normalPileup = re.sub(".bam$",".pileup",normalBam)
		if not os.path.isfile(normalPileup):
			print "Creating normal .pileup file"
			command ="samtools mpileup -C50 -f " + ref + " " + normalBam + " > " + normalPileup
			os.system(command)

		tumorPileup = re.sub(".bam$",".pileup",tumorBam)
		if not os.path.isfile(tumorPileup):
			print "Creating tumor .pileup file"
			command ="samtools mpileup -C50 -f " + ref + " " + tumorBam + " > " + tumorPileup
			os.system(command)
			
		#you can create .vcf with --output-vcf, but then you have to parse out somatic variants and combine SNP and indel files
		command = "java -Xmx" + java_mem+ " -jar "+varscan_jar+" somatic " + normalPileup + " " + tumorPileup + " " + varscanPrefix + " --min-var-freq 0.3 --min-avg-qual 20 --p-value 0.01 --somatic-p-value 0.01 --min-coverage-normal 10 --min-coverage-tumor 10 --strand-filter 1"
		os.system(command)

		command = "java -Xmx" + java_mem+ " -jar "+varscan_jar+" copynumber " + normalPileup + " " + tumorPileup + " " + varscanPrefix + " --p-value 0.01 --min-coverage 10 --max-segment-size 10000000"
		os.system(command)
		
		command = "java -Xmx" + java_mem+ " -jar "+varscan_jar+" copyCaller " + varscanPrefix + ".copynumber --output-file "+ varscanPrefix + ".copynumber.called " + " --output-homdel-file "  + varscanPrefix+ ".copynumber.called.homdel"
		os.system(command)
		
#delete .pileup files manually - just in case you want to use the same normal / tumor sample more than once
