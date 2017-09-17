import sys
import re
import os

muTectPrefixes = ("Somatic_[Tumor ID]_vs_[Normal ID].mutect2")

resultFolder = "MuTect_Somatic_Variants/"
annovarPath = "/path/to/ANNOVAR/"
build = "hg19"
threads = "2"
	
for prefix in muTectPrefixes:
	print "\n\n" + prefix + "\n\n"
	vcf = prefix + ".vcf"
	outPrefix = resultFolder + prefix
	command = annovarPath + "convert2annovar.pl -format vcf4 " + vcf + " -allsample -outfile " + outPrefix
	os.system(command)
	
	annovarVar = outPrefix + ".TUMOR.avinput" 
			
	resultSubfolder = resultFolder + "/" + prefix
	command = "mkdir " + resultSubfolder
	os.system(command)

	annotationPrefix = resultSubfolder + "/" + prefix
	if build == "hg19":
		command = annovarPath + "table_annovar.pl --otherinfo " + annovarVar +" " + annovarPath + "humandb/ -csvout -buildver "+build+" -out " + annotationPrefix +" -protocol refGene,clinvar_20160302,cosmic70,nci60,kaviar_20150923,hrcr1,dbnsfp30a,gnomad_exome,avsnp147,cadd13gt20,gwava -operation g,f,f,f,f,f,f,f,f,f,f -nastring NA --thread " + threads
		os.system(command)
	else:
		command = annovarPath + "table_annovar.pl --otherinfo " + annovarVar +" " + annovarPath + "humandb/ -csvout -buildver "+build+" -out " + annotationPrefix +" -protocol refGene,clinvar_20160302,cosmic70,nci60,kaviar_20150923,hrcr1,dbnsfp30a,gnomad_exome,avsnp147 -operation g,f,f,f,f,f,f,f,f -nastring NA --thread " + threads
		os.system(command)

	bedAnn = build + "_GWAScatalog.bed"
	annotationPrefix = resultSubfolder + "/" + prefix + "_annovar_GWAS_Catalog"
	command = annovarPath + "annotate_variation.pl " + annovarVar +" " + annovarPath + "humandb/ -buildver "+build+" -out " + annotationPrefix +" -bedfile " + bedAnn + " -dbtype bed -regionanno -colsWanted 4"
	os.system(command)

	bedAnn = build + "_RepeatMasker.bed"
	annotationPrefix = resultSubfolder + "/" + prefix + "_annovar_RepeatMasker"
	command = annovarPath + "annotate_variation.pl " + annovarVar +" " + annovarPath + "humandb/ -buildver "+build+" -out " + annotationPrefix +" -bedfile " + bedAnn + " -dbtype bed -regionanno -colsWanted 4"
	os.system(command)
			
	#bed annotation mostly works OK, but bedtools was more accurate for ORegAnno hit (probably because it isn't sorted)
	bedAnn = annovarPath + "/humandb/" + build + "_ORegAnno.bed"
	bedOut = resultSubfolder + "/" + prefix + "_bedtools_ORegAnno.bed"
	command = "/opt/bedtools2/bin/bedtools intersect -wa -wb -a " + annovarVar +" -b " + bedAnn + " > " + bedOut
	os.system(command)
			
	#minor formatting modification to work with variant summary script
	oregannoANNOVAR= resultSubfolder + "/" + prefix + "_bedtools_ORegAnno.avinput"
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