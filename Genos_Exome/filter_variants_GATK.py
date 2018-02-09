import sys
import re
import os

vcfPrefix = "BWA-MEM_realign.GATK.HC"
summary_file = "Exome_stats.txt"

#use RefSeq CDS as target region
targetBED = "RefSeq_genes_CDS.bed"

##can also get same variants for WGS data, even though goal isn't really to filter off-target variants in that case...although you might find you can call more CDS variants with lower coverage WGS data
#vcfPrefix = "hg19.gatk.GATK.HC"
#summary_file = "WGS_stats.txt"

#assume code tests GATK 4.0.1, using 1) default, 2) skip soft-clipped bases, and 3) flagging variants without using soft-clipped bases
vcfFiles = (vcfPrefix + ".vcf", vcfPrefix + ".nosoftclip.vcf", vcfPrefix + ".nosoftclip.filtered.vcf")

statHandle = open(summary_file,"w")
text = "VCF\tSNP.count\tIns.count\tDel.count\tlocation.filtered.SNP.count\tlocation.filtered.Ins.count\tlocation.filtered.Del.count\n"
statHandle.write(text)


for vcfIn in vcfFiles:
	snpCounts = 0
	insertionCounts = 0
	deletionCounts = 0
	
	print "QC Filter for variants in " + vcfIn
	vcfFlagFilter = re.sub(".vcf$",".QC-filtered.vcf",vcfIn)
			
	outHandle = open(vcfFlagFilter,"w")
			
	inHandle = open(vcfIn)
	line = inHandle.readline()
			
	while line:
				
		commentResult = re.search("^#",line)
				
		if commentResult:
			outHandle.write(line)
		else:
			lineInfo = line.split("\t")
			chr = lineInfo[0]
			variantStatus = lineInfo[6]
					
			if ((variantStatus == "PASS") or (variantStatus == ".")):

				refSeq = lineInfo[3]
				varSeq = lineInfo[4]
						
				if (len(refSeq) == 1) and (len(varSeq) == 1):
					snpCounts += 1
				else:
					#for summary, don't count complex variants..but count other types of variants
					multVarResult = re.search(",",varSeq)
							
					if multVarResult:
						refVars = varSeq.split(",")
						for testVar in refVars:
							if testVar != refSeq:
								if (len(refSeq) == 1) and (len(testVar) == 1):
									snpCounts += 1
								elif len(testVar) > len(refSeq):
									insertionCounts += 1
								elif len(testVar) < len(refSeq):
									deletionCounts += 1										
					elif len(varSeq) > len(refSeq):
						insertionCounts += 1
					elif len(varSeq) < len(refSeq):
						deletionCounts += 1
							
				outHandle.write(line)	
			elif (variantStatus != "SnpCluster") and (variantStatus != "QC")and (variantStatus != "FS")and (variantStatus != "FS;QC") and (variantStatus != "FS;SnpCluster")and (variantStatus != "FS;QC;SnpCluster") and (variantStatus != "QC;SnpCluster")and (variantStatus != "FS;QD;SnpCluster")and (variantStatus != "QD;SnpCluster")and (variantStatus != "QD")and (variantStatus != "FS;QD"):
				print "QC-Filter Step...Modify code to Keep or Skip variant status: " + variantStatus
				print "QC-Filter Step...Example Line: " + line
				sys.exit()
				
		line = inHandle.readline()
	inHandle.close()
	outHandle.close()
			
	text = vcfIn + "\t" + str(snpCounts) + "\t" + str(insertionCounts) + "\t" + str(deletionCounts)

	#Target-regions filer
	print "On-Target Filter for variants in " + vcfIn
	keptSnps = 0
	keptIns = 0
	keptDel = 0
			
	targetVCF = re.sub(".vcf$",".target_filtered.vcf",vcfFlagFilter)
			
	command = "/opt/bedtools2/bin/bedtools intersect -header -f 1 -a " + vcfFlagFilter + " -b " + targetBED + " > " + targetVCF
	os.system(command)

	inHandle = open(targetVCF)
	line = inHandle.readline()
			
	while line:		
		commentResult = re.search("^#",line)
				
		if not commentResult:
			lineInfo = line.split("\t")
			chr = lineInfo[0]
			variantStatus = lineInfo[6]
					
			if ((variantStatus == "PASS")|(variantStatus == ".")):

				refSeq = lineInfo[3]
				varSeq = lineInfo[4]
						
				if (len(refSeq) == 1) and (len(varSeq) == 1):
					keptSnps += 1
				else:
					multVarResult = re.search(",",varSeq)
					
					#again, don't count complex variants..but count other types of variants
					
					if multVarResult:
						refVars = varSeq.split(",")
						for testVar in refVars:
							if testVar != refSeq:
								if (len(refSeq) == 1) and (len(testVar) == 1):
									keptSnps += 1
								elif len(testVar) > len(refSeq):
									keptIns += 1
								elif len(testVar) < len(refSeq):
									keptDel += 1									
					elif len(varSeq) > len(refSeq):
						keptIns += 1
					elif len(varSeq) < len(refSeq):
						keptDel += 1	
			else:
				print "Target-Filter Step...Modify code to Keep or Skip variant status: " + variantStatus
				print "Target-Filter Step...Example Line: " + line
				sys.exit()
				
		line = inHandle.readline()
	inHandle.close()
						
	text = text + "\t" + str(keptSnps) + "\t" + str(keptIns) + "\t" + str(keptDel) + "\n"
	statHandle.write(text)