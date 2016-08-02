import sys
import re
import os
import csv

input= ""
caller = "Veritas"
javaMem = "4g"
refDb = "GRCh37.75"

for arg in sys.argv:
	inputResult = re.search("^--input=(.*)",arg)
	callerResult = re.search("^--caller=(.*)",arg)
	refDbResult = re.search("^--db=(.*)",arg)
	memResult = re.search("^--java_mem=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if inputResult:
		input = inputResult.group(1)

	if callerResult:
		caller = callerResult.group(1)
		
	if memResult:
		javaMem = memResult.group(1)

	if refDbResult:
		refDb = refDbResult.group(1)
		
	if helpResult:
		print "Usage: python combine_bams.py --input=[file.vcf|file.bed] --caller=Veritas --db=CRCh37.75 --java_mem=4g\n"
		print "--caller : Algorithm used to call variants\n"
		print "--input : File containing variants (.vcf for Veritas, .bed for SVs)\n"
		print "--db : snpEff reference/annotation database\n"
		print "--java_mem : Java memory limit for SnpEff\n"
		sys.exit()

vcfCheck = re.search(".vcf$",input)
		
if caller == "Veritas":
	if (not vcfCheck):
		print "You must provide a vcf --input file"
		sys.exit()
else:
	print "Need to provide valid --caller and --input combination"
	sys.exit()
	
if caller == "Veritas":
	tempVcf = "temp.vcf"
	outHandle = open(tempVcf, 'w')
	
	totalVariants = 0
	passVariants = 0
	
	inHandle = open(input)
	line = inHandle.readline()
			
	totalReads = ""
			
	while line:
		line = re.sub("\n","",line)
		line = re.sub("\r","",line)

		commentFlag = re.search("^#",line)
		
		if commentFlag:
			text = line + "\n"
			outHandle.write(text)
		else:
			totalVariants += 1
			lineInfo = line.split("\t")
			if lineInfo[5] != ".":
				qual = float(lineInfo[5])
				annText = lineInfo[7]
				if qual > 20:
					dpResult = re.search(";DP=(\d+);",annText)
					aoResult = re.search(";AO=(\d+);",annText)
					if dpResult and aoResult:
						dp = int(dpResult.group(1))
						ao = int(aoResult.group(1))
						obAF = float(ao)/float(dp)
						if (dp > 10) & (obAF >= 0.3):
							passVariants +=1
							if lineInfo[0] == "M":
								lineInfo[0] = "MT"
							lineInfo[0] = re.sub("chr","",lineInfo[0])
							text = "\t".join(lineInfo) + "\n"
							outHandle.write(text)
		line = inHandle.readline()	
		
	percentPass = 100 * float(passVariants)/float(totalVariants)
	print str(passVariants) + " ("+ '{:.2f}'.format(percentPass) +"%) variants used for snpEff"
	
	snpEffAnn = "snpEff_annotations.vcf"
	command = "java -jar -Xmx" + javaMem + " /opt/snpEff/snpEff.jar " + refDb + " " + tempVcf + " > " + snpEffAnn
	os.system(command)
	
	command = "rm "+ tempVcf
	os.system(command)
else:
	print "Template currently only written for Veritas / VCF annoations"