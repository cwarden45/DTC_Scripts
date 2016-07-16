import sys
import re
import os

vcf= ""
caller = "Veritas"
damaging = "use"

for arg in sys.argv:
	vcfResult = re.search("^--vcf=(.*)",arg)
	callerResult = re.search("^--caller=(.*)",arg)
	damagingResult = re.search("^--damaging=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if vcfResult:
		vcf = vcfResult.group(1)

	if callerResult:
		caller = callerResult.group(1)
		
	if damagingResult:
		damaging = damagingResult.group(1)
		
	if helpResult:
		print "Usage: python combine_bams.py --vcf=file.vcf --caller=Veritas --damaging=use\n"
		print "--vcf : VCF file containing variants\n"
		print "--damaging : Use damaging prediction for SNPs and small indels?  'skip' or 'use'\n"
		print "--caller : Algorithm used to call variants\n"
		sys.exit()
	
if caller == "Veritas":
	if damaging != "skip":
		print "**Downloading 7 ANNOVAR Databases (might take a several minutes)**"
		print "WARNING: If you have limited space on your hard drive, you may want to re-run this script with --damaging=skip"
	else:
		print "**Downloading 6 ANNOVAR Databases (might take a several minutes)**"
	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene annovar/humandb/"
	os.system(command)

	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar clinvar_20160302 annovar/humandb/"
	os.system(command)

	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar 1000g2015aug annovar/humandb/"
	os.system(command)
	
	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar kaviar_20150923 annovar/humandb/"
	os.system(command)

	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar hrcr1 annovar/humandb/"
	os.system(command)
	
	command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar cg69 annovar/humandb/"
	os.system(command)
	
	if damaging != "skip":
		command = "annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp30a annovar/humandb/"
		os.system(command)

	print "**Creating Annotation Table (the whole-genome WGS file is quite large, so this may also take a several minutes)**"
	print "NOTE: You may see error messages pop up - don't worry about those.  You'll still probably get your final results."
	annotationPrefix = "annovar_" + re.sub(".vcf$","",vcf)
	annovarVar = annotationPrefix + ".avinput"
	command = "annovar/convert2annovar.pl -format vcf4 -coverage 10 -fraction 0.3 " + vcf + " > " + annovarVar
	os.system(command)
	
	if damaging == "skip":
		command = "annovar/table_annovar.pl " + annovarVar +" annovar/humandb/ -csvout -buildver hg19 -out " + annotationPrefix +" -remove -protocol refGene,clinvar_20160302,ALL.sites.2015_08,kaviar_20150923,hrcr1,cg69 -operation g,f,f,f,f,f -nastring NA"
		os.system(command)	
	else:	
		command = "annovar/table_annovar.pl " + annovarVar +" annovar/humandb/ -csvout -buildver hg19 -out " + annotationPrefix +" -remove -protocol refGene,clinvar_20160302,ALL.sites.2015_08,kaviar_20150923,hrcr1,cg69,dbnsfp30a -operation g,f,f,f,f,f,f -nastring NA"
		os.system(command)
else:
	print "Template currently only written for Veritas / VCF annoations"