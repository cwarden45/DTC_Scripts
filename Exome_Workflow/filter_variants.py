import sys
import re
import os
import subprocess

#input and output is for hard filtering applied in this code

parameterFile = "parameters.txt"
finishedSamples = ()

alignmentFolder = ""
targetBED = ""
variant_caller = ""
GATK_filter = ""
summary_file = ""

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

	if param == "target_bed":
		targetBED = value

	if param == "variant_caller":
		variant_caller = value	

	if param == "GATK_filter":
		GATK_filter = value	
		
	if param == "target_filter_summary":
		summary_file = value
	
if (alignmentFolder == "") or (alignmentFolder == "[required]"):
	print "Need to enter a value for 'Alignment_Folder'!"
	sys.exit()
	
if (targetBED == "") or (targetBED == "[required]"):
	print "Need to enter a value for 'target_bed'!"
	sys.exit()
	
if (variant_caller == "") or (variant_caller == "[required]"):
	print "Need to enter a value for 'variant_caller'!"
	sys.exit()
	
if (GATK_filter == "") or (GATK_filter == "[required]"):
	print "Need to enter a value for 'GATK_filter'!"
	sys.exit()	
	
if (summary_file== "") or (summary_file == "[required]"):
	print "Need to enter a value for 'target_filter_summary'!"
	sys.exit()
	
fileResults = os.listdir(alignmentFolder)

statHandle = open(summary_file,"w")
text = "Sample\tSNP.count\tIns.count\tDel.count\tlocation.filtered.SNP.count\tlocation.filtered.Ins.count\tlocation.filtered.Del.count\n"
statHandle.write(text)

for file in fileResults:
	result = re.search("(.*).bam$",file)
	
	if result:
		sample = result.group(1)
		
		if (sample not in finishedSamples):
			print sample
			filteredBam = alignmentFolder + "/" + file
			
			outputSubfolder = alignmentFolder +"/" + sample
			
			if variant_caller == "GATK-HC":
				if GATK_filter == "yes":
					vcfIn = outputSubfolder + "/" + sample + ".GATK.HC.flagged.vcf"
				else:
					vcfIn = outputSubfolder + "/" + sample + ".GATK.HC.full.vcf"
			elif variant_caller == "VarScan":
				print "Need to add VarScan-Cons code"
				sys.exit()
			else:
				print "Code currently only supported for 'variant_caller' set to 'GATK-HC' or 'VarScan'"
				sys.exit()
			
			snpCounts = 0
			insertionCounts = 0
			deletionCounts = 0
			
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
										else:
											print "Modify code to count ref: " + refSeq + ", var: " + varSeq										
							elif len(varSeq) > len(refSeq):
								insertionCounts += 1
							elif len(varSeq) < len(refSeq):
								deletionCounts += 1
							else:
								print "Modify code to count ref: " + refSeq + ", var: " + varSeq
							
						outHandle.write(line)	
					elif (variantStatus != "SnpCluster") and (variantStatus != "QC")and (variantStatus != "FS")and (variantStatus != "FS;QC") and (variantStatus != "FS;SnpCluster")and (variantStatus != "FS;QC;SnpCluster") and (variantStatus != "QC;SnpCluster"):
						print "Modify code to Keep or Skip variant status: " + variantStatus
						print "Example Line: " + line
						sys.exit()
				
				line = inHandle.readline()
			inHandle.close()
			outHandle.close()
			
			text = sample + "\t" + str(snpCounts) + "\t" + str(insertionCounts) + "\t" + str(deletionCounts)

			#Target-regions filer
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
										else:
											print "Modify code to count ref: " + refSeq + ", var: " + varSeq										
							elif len(varSeq) > len(refSeq):
								keptIns += 1
							elif len(varSeq) < len(refSeq):
								keptDel += 1
							else:
								print "Modify code to count ref: " + refSeq + ", var: " + varSeq	
					else:
						print "Target-Filter Step...Modify code to Keep or Skip variant status: " + variantStatus
						print "Target-Filter Step...Example Line: " + line
						sys.exit()
				
				line = inHandle.readline()
			inHandle.close()
						
			text = text + "\t" + str(keptSnps) + "\t" + str(keptIns) + "\t" + str(keptDel) + "\n"
			statHandle.write(text)