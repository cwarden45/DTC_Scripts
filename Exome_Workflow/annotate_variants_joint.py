import sys
import re
import os

jointVCF = "joint_variant_calls.GATK.HC.filtered.target_filtered.vcf"
resultFolder = "../Result/Joint_GATK_Variant_Calls/"

finishedSamples = ()
parameterFile = "parameters.txt"
annovarPath = ""
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
	

	if param == "ANNOVAR_Path":
		annovarPath = value	

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
		
if (annovarPath == "") or (annovarPath == "[required]"):
	print "Need to enter a value for 'ANNOVAR_Path'!"
	sys.exit()
	

outPrefix = resultFolder + "joint"
command = annovarPath + "convert2annovar.pl -format vcf4 " + jointVCF + " -allsample -outfile " + outPrefix
os.system(command)

fileResults = os.listdir(resultFolder)
	
for file in fileResults:
	result = re.search("joint.(.*).avinput$",file)
	
	if result:
		sample = result.group(1)
		
		if (sample not in finishedSamples):
			print "\n\n" + sample + "\n\n"
			
			resultSubfolder = resultFolder + "/" + sample
			command = "mkdir " + resultSubfolder
			os.system(command)
			
			annovarVar = resultFolder + "joint." + sample + ".avinput"

			annotationPrefix = resultSubfolder + "/" + sample
			if build == "hg19":
				command = annovarPath + "table_annovar.pl --otherinfo " + annovarVar +" " + annovarPath + "humandb/ -csvout -buildver "+build+" -out " + annotationPrefix +" -protocol refGene,clinvar_20160302,cosmic70,nci60,kaviar_20150923,gnomad_exome,hrcr1,dbnsfp30a,avsnp147,cadd13gt20,gwava -operation g,f,f,f,f,f,f,f,f,f,f -nastring NA --thread " + threads
				os.system(command)
			else:
				command = annovarPath + "table_annovar.pl --otherinfo " + annovarVar +" " + annovarPath + "humandb/ -csvout -buildver "+build+" -out " + annotationPrefix +" -protocol refGene,clinvar_20160302,cosmic70,nci60,kaviar_20150923,gnomad_exome,hrcr1,dbnsfp30a,avsnp147 -operation g,f,f,f,f,f,f,f,f -nastring NA --thread " + threads
				os.system(command)

			bedAnn = build + "_GWAScatalog.bed"
			annotationPrefix = resultSubfolder + "/" + sample + "_annovar_GWAS_Catalog"
			command = annovarPath + "annotate_variation.pl " + annovarVar +" " + annovarPath + "humandb/ -buildver "+build+" -out " + annotationPrefix +" -bedfile " + bedAnn + " -dbtype bed -regionanno -colsWanted 4"
			os.system(command)

			bedAnn = build + "_RepeatMasker.bed"
			annotationPrefix = resultSubfolder + "/" + sample + "_annovar_RepeatMasker"
			command = annovarPath + "annotate_variation.pl " + annovarVar +" " + annovarPath + "humandb/ -buildver "+build+" -out " + annotationPrefix +" -bedfile " + bedAnn + " -dbtype bed -regionanno -colsWanted 4"
			os.system(command)
			
			#bed annotation mostly works OK, but bedtools was more accurate for ORegAnno hit (probably because it isn't sorted)
			bedAnn = annovarPath + "/humandb/" + build + "_ORegAnno.bed"
			bedOut = resultSubfolder + "/" + sample + "_bedtools_ORegAnno.bed"
			command = "/opt/bedtools2/bin/bedtools intersect -wa -wb -a " + annovarVar +" -b " + bedAnn + " > " + bedOut
			os.system(command)
			
			#minor formatting modification to work with variant summary script
			oregannoANNOVAR= resultSubfolder + "/" + sample + "_bedtools_ORegAnno.avinput"
			outHandle = open(oregannoANNOVAR,"w")
			
			inHandle = open(bedOut)
			line = inHandle.readline()
			
			while line:
				lineInfo = line.split("\t")
				chr = lineInfo[0]
				start = lineInfo[1]
				stop = lineInfo[2]
				ref = lineInfo[3]
				var = lineInfo[4]
				type = lineInfo[5]
				somatic_pvalue = lineInfo[6]
				totalCov = lineInfo[7]
				oreg = lineInfo[11]
					
				text = chr + "\t" + start+ "\t" + stop + "\t" + ref + "\t" + var + "\t" + type + "\t" + somatic_pvalue+ "\t" + oreg + "\n"
				outHandle.write(text)
						
				line = inHandle.readline()
			inHandle.close()
			outHandle.close()
