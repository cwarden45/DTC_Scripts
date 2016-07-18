import sys
import re
import os
import csv

vcf= ""
caller = "Veritas"
damaging = "use"
ancestry1KG = "EUR"

for arg in sys.argv:
	vcfResult = re.search("^--vcf=(.*)",arg)
	callerResult = re.search("^--caller=(.*)",arg)
	damagingResult = re.search("^--damaging=(.*)",arg)
	ancestryResult = re.search("^--ancestry=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if vcfResult:
		vcf = vcfResult.group(1)

	if callerResult:
		caller = callerResult.group(1)
		
	if damagingResult:
		damaging = damagingResult.group(1)

	if ancestryResult:
		ancestry1KG = ancestryResult.group(1)
		
	if helpResult:
		print "Usage: python combine_bams.py --vcf=file.vcf --caller=Veritas --damaging=use --ancestry=EUR\n"
		print "--vcf : VCF file containing variants\n"
		print "--damaging : Use damaging prediction for SNPs and small indels?  'skip' or 'use'\n"
		print "--ancestry : 1000 Genomes Ancestry: EUR (European), AFR (African), AMR (Mixed/Central American), SAS (South Asian), EAS (East Asian), or ALL\n"
		print "--caller : Algorithm used to call variants\n"
		sys.exit()
		
if vcf =="":
	print "You must provide a --vcf file name"
	sys.exit()
	
if caller == "Veritas":
	if damaging != "skip":
		print "**Downloading 4 ANNOVAR Databases (might take a several minutes)**"
		print "WARNING: If you have limited space on your hard drive, you may want to re-run this script with --damaging=skip"
	else:
		print "**Downloading 3 ANNOVAR Databases (might take a several minutes)**"
	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene annovar/humandb/"
	os.system(command)

	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar clinvar_20160302 annovar/humandb/"
	os.system(command)

	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar popfreq_all_20150413 annovar/humandb/"
	os.system(command)s
	
	if damaging != "skip":
		command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar ljb26_all annovar/humandb/"
		os.system(command)

	print "**Creating Annotation Table (the whole-genome WGS file is quite large, so this may take several minutes)**"
	print "NOTE: You may see error messages pop up - don't worry about those.  You'll still probably get your final results."
	annotationPrefix = "annovar_" + re.sub(".vcf$","",vcf)
	annovarVar = annotationPrefix + ".avinput"
	command = "annovar/convert2annovar.pl -format vcf4 -coverage 10 -fraction 0.3 " + vcf + " > " + annovarVar
	os.system(command)

	command = "annovar/table_annovar.pl " + annovarVar +" annovar/humandb/ -csvout -buildver hg19 -out " + annotationPrefix +" -protocol refGene,clinvar_20160302,popfreq_all_20150413 -operation g,f,f -nastring NA"
	os.system(command)
	
	annovarTable = annotationPrefix + ".hg19_multianno.csv"
	filteredVar2 = annotationPrefix + "_ClinVar_Pathogenic_plus_Rare.txt"
	outHandle = open(filteredVar2, 'w')
	
	with open(annovarTable, 'rb') as csvfile:
		reader = csv.reader(csvfile)
		lineInfo = reader.next()
		
		lineCount = 0
		
		while len(lineInfo) > 1:
			lineCount += 1
			
			if lineCount > 1:
				chr = lineInfo[0]
				start = lineInfo[1]
				stop = lineInfo[2]
				ref = lineInfo[3]
				alt = lineInfo[4]
				
				ClinVar = lineInfo[10]
				pathResult = re.search("Pathogenic|pathogenic",ClinVar)
				
				if pathResult:
					text = chr + "\t" + start + "\t" + stop + "\t" + ref + "\t" + alt + "\t" + "\n"
					outHandle.write(text)						
				else:
					#1KG
					freq1 = 0
					#ESP
					freq2 = 0
					#CG
					freq3 = 0
					
					if ancestry1KG == "ALL":
						if (lineInfo[16] != "NA") & (lineInfo[16] != "."):
							freq1 = float(lineInfo[16])
						if (lineInfo[30] != "NA") & (lineInfo[30] != "."):
							freq2 = float(lineInfo[30])
					elif ancestry1KG == "AFR":
						if (lineInfo[17] != "NA") & (lineInfo[17] != "."):
							freq1 = float(lineInfo[17])
						if (lineInfo[31] != "NA") & (lineInfo[31] != "."):
							freq2 = float(lineInfo[31])
					elif ancestry1KG == "AMR":
						if (lineInfo[18] != "NA") & (lineInfo[18] != "."):
							freq1 = float(lineInfo[18])
						if (lineInfo[30] != "NA") & (lineInfo[30] != "."):
							freq2 = float(lineInfo[30])
					elif ancestry1KG == "EAS":
						if (lineInfo[19] != "NA") & (lineInfo[19] != "."):
							freq1 = float(lineInfo[19])
						if (lineInfo[30] != "NA") & (lineInfo[30] != "."):
							freq2 = float(lineInfo[30])
					elif ancestry1KG == "EUR":
						if (lineInfo[20] != "NA") & (lineInfo[20] != "."):
							freq1 = float(lineInfo[20])
						if (lineInfo[32] != "NA") & (lineInfo[32] != "."):
							freq2 = float(lineInfo[32])
					elif ancestry1KG == "SAS":
						if (lineInfo[21] != "NA") & (lineInfo[21] != "."):
							freq1 = float(lineInfo[21])
						if (lineInfo[30] != "NA") & (lineInfo[30] != "."):
							freq2 = float(lineInfo[30])
					else:
						print "Ancestry must be EUR, AFR (African), AMR (Mixed/Central American), SAS (South Asian), EAS (East Asian), or ALL"
						sys.exit
					
					if (lineInfo[33] != "NA") & (lineInfo[33] != "."):
						freq3 = float(lineInfo[33])
						
					if (freq1 < 0.01) & (freq2 < 0.01) & (freq3 < 0.01):
						text = chr + "\t" + start + "\t" + stop + "\t" + ref + "\t" + alt + "\t" + "\n"
						outHandle.write(text)

			try:
				lineInfo = reader.next()
			except:
				break
	
	if damaging != "skip":	
		damPrefix = annotationPrefix + "_ClinVar_Pathogenic_plus_Rare_with_Damaging_Score"
		command = "annovar/table_annovar.pl " + filteredVar2 +" annovar/humandb/ -csvout -buildver hg19 -out " + damPrefix +" -protocol refGene,ljb26_all -operation g,f -nastring NA"
		os.system(command)
else:
	print "Template currently only written for Veritas / VCF annoations"