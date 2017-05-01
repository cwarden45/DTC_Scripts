import sys
import re
import os

vcfExt = ".GATK.HC.flagged.QC-filtered.target_filtered.vcf"

parameterFile = "parameters.txt"
finishedSamples = ()

alignmentFolder = ""
annovarPath = ""
resultFolder = ""
build = ""
threads = ""

inHandle = open(parameterFile)
lines = inHandle.readlines()
			
for line in lines:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	param = lineInfo[0]
	value = lineInfo[1]
	
	if param == "Alignment_Folder":
		alignmentFolder = value

	if param == "ANNOVAR_Path":
		annovarPath = value

	if param == "Result_Folder":
		resultFolder = value		

	if param == "Threads":
		threads = value
		
	if param == "genome":
		build = value

if (build == "") or (build == "[required]"):
	print "Need to enter a value for 'genome'!"
	sys.exit()
	
if (threads == "") or (threads == "[required]"):
	print "Need to enter a value for 'Threads'!"
	sys.exit()
		
if (alignmentFolder == "") or (alignmentFolder == "[required]"):
	print "Need to enter a value for 'Alignment_Folder'!"
	sys.exit()
	
if (annovarPath == "") or (annovarPath == "[required]"):
	print "Need to enter a value for 'ANNOVAR_Path'!"
	sys.exit()
	
if (resultFolder == "") or (resultFolder == "[required]"):
	print "Need to enter a value for 'Result_Folder'!"
	sys.exit()

fileResults = os.listdir(alignmentFolder)

for file in fileResults:
	result = re.search("(.*).bam$",file)
	
	if result:
		sample = result.group(1)
		
		if (sample not in finishedSamples):
			print "\n\n" + sample + "\n\n"
			
			resultSubfolder = resultFolder + "/" + sample
			command = "mkdir " + resultSubfolder
			os.system(command)
			
			alignmentSubfolder = alignmentFolder +"/" + sample
			
			vcf = alignmentSubfolder + "/" + sample + vcfExt
			
			annovarVar = resultSubfolder + "/" + sample + ".avinput"
			command = annovarPath + "convert2annovar.pl -format vcf4 " + vcf + " > " + annovarVar
			os.system(command)

			annotationPrefix = resultSubfolder + "/" + sample
			if build == "hg19":
				command = annovarPath + "table_annovar.pl --otherinfo " + annovarVar +" " + annovarPath + "humandb/ -csvout -buildver "+build+" -out " + annotationPrefix +" -protocol refGene,clinvar_20160302,cosmic70,nci60,kaviar_20150923,hrcr1,dbnsfp30a,gnomad_exome,avsnp147,cadd13gt20,gwava -operation g,f,f,f,f,f,f,f,f,f,f -nastring NA --thread " + threads
				os.system(command)
			else:
				command = annovarPath + "table_annovar.pl --otherinfo " + annovarVar +" " + annovarPath + "humandb/ -csvout -buildver "+build+" -out " + annotationPrefix +" -protocol refGene,clinvar_20160302,cosmic70,nci60,kaviar_20150923,hrcr1,dbnsfp30a,gnomad_exome,avsnp147 -operation g,f,f,f,f,f,f,f,f -nastring NA --thread " + threads
				os.system(command)
			
			bedAnn = build + "_GWAScatalog.bed"
			annotationPrefix = resultSubfolder + "/" + sample + "_annovar_GWAS_Catalog"
			command = annovarPath + "annotate_variation.pl " + annovarVar +" " + annovarPath + "humandb/ -buildver "+build+" -out " + annotationPrefix +" -bedfile " + bedAnn + " -dbtype bed -regionanno -colsWanted 4"
			os.system(command)

			#bed annotation mostly works OK, but bedtools was more accurate for ORegAnno hit (probably because it isn't sorted)
			bedAnn = annovarPath + "/humandb/" + build + "_ORegAnno.bed"
			bedOut = resultSubfolder + "/" + sample + "_bedtools_ORegAnno.bed"
			command = "/opt/bedtools2/bin/bedtools intersect -wa -wb -a " + vcf +" -b " + bedAnn + " > " + bedOut
			os.system(command)
			
			oregannoVCF = resultSubfolder + "/" + sample + "_bedtools_ORegAnno.vcf"
			outHandle = open(oregannoVCF,"w")

			inHandle = open(bedOut)
			line = inHandle.readline()
			
			while line:
				lineInfo = line.split("\t")
				ORegAnnoID = lineInfo[len(lineInfo)-3]
				lineInfo[2] = ORegAnnoID
				
				text = "\t".join(lineInfo)
				outHandle.write(text)
				
				line = inHandle.readline()
			inHandle.close()
			outHandle.close()
			
			oregannoANNOVAR= resultSubfolder + "/" + sample + "_bedtools_ORegAnno.avinput"
			command = annovarPath + "convert2annovar.pl -format vcf4 --includeinfo " + oregannoVCF + " > " + oregannoANNOVAR
			os.system(command)