import sys
import re
import os

smallVCF = "23andMe.vcf"
largeVCF = ""
outputFile = ""

for arg in sys.argv:
	smallResult = re.search("^--smallVCF=(.*)",arg)
	largeResult = re.search("^--largeVCF=(.*)",arg)
	outputResult = re.search("^--output=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if smallResult:
		smallVCF = smallResult.group(1)

	if largeResult:
		largeVCF = largeResult.group(1)

	if outputResult:
		outputFile = outputResult.group(1)
		
	if helpResult:
		print "Usage: python VCF_recovery.py --smallVCF=[23andMe_variants].vcf --largeVCF=[Veritas_variants].vcf --output=[smallID]_in=_[largeID]_discordant.vcf\n"
		print "--smallVCF : List of variants to recover in VCF format\n"
		print "--largeVCF : List of variants to test in VCF format\n"
		print "--output : Manually specify output file.  Otherwise, set to [smallID]_in=_[largeID]_discordant.vcf\n"
		sys.exit()
		
if smallVCF == "":
	print "Must specify a --smallVCF with list of variants to recover (such as 23andMe variants)"
	sys.exit()

if largeVCF == "":
	print "Must specify a --largeVCF with list of validation variants (such as Veritas WGS variants)"
	sys.exit()
	
if outputFile == "":
	smallBase = os.path.basename(os.path.normpath(smallVCF))
	largeBase =  os.path.basename(os.path.normpath(largeVCF))
	smallResult = re.search("\.vcf$",smallVCF.lower())
	largeResult = re.search("\.vcf$",largeVCF.lower())
	if not smallResult:
		print "--smallVCF file does not have proper extension (.vcf or .VCF)"
		sys.exit()
	elif not largeResult:
		print "--largeVCF file does not have proper extension (.vcf or .VCF)"
		sys.exit()
	else:
		smallID = smallBase[:-4]
		largeID = largeBase[:-4]
		outputFile = smallID + "_in_" + largeID + "_discordant.vcf"
	print "Writing missing variants in " + outputFile

#read small VCF
smallCalledSites = 0
smallPosHash = {}
smallVarHash = {}

inHandle = open(smallVCF)
line = inHandle.readline()
			
totalReads = ""
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	commentFlag = re.search("^#",line)
	
	if not commentFlag:	
		lineInfo = line.split("\t")
		chr = lineInfo[0]
		pos = lineInfo[1]
		varID = lineInfo[2]
		ref = lineInfo[3]
		var = lineInfo[4]
		flag = lineInfo[6]
		
		calledFlag = re.search("nocall",flag)
		
		if not calledFlag:
			smallCalledSites +=1
		
			genotypeResult = re.search("^GT",lineInfo[8])
			if genotypeResult:
				callText = lineInfo[9]
				callInfo = callText.split(":")
				genotype = callInfo[0]
			else:
				print "Need to extract genotype from different position " + lineInfo[8]
				sys.exit()
				
			if (genotype != "0/0") and (genotype != "0"):
				smallPos = chr + "\t" + pos
				smallPosHash[smallPos] = varID + "\t" + ref + "\t" + var + "\t" + flag

				smallVarID = chr + "\t" + pos + "\tNA\t" + ref + "\t" + var
				smallVarHash[smallVarID] = genotype
			
	line = inHandle.readline()
	
refVarCount = len(smallPosHash.keys())
percentVar = 100 * float(refVarCount) / float(smallCalledSites)
print smallID + " : " + str(refVarCount) + " / " + str(smallCalledSites) + " ("+'{:.2f}'.format(percentVar)+"%) called sites with variation from reference"

#read large VCF and output discordant variants at same position
fullRecoveryHash = {}
partialRecoveryHash = {}
discordantHash = {}

outHandle = open(outputFile, 'w')
text = "#ID is from small VCF\n"
text = "#FLAG is from small VCF\n"
text = text + "#QUAL is from large VCF\n"
text = text + "#"+smallID+" is genotype for small VCF (discordant or missed variants)\n"
text = text + "#"+largeID+" is genotype for large VCF (discordant genotype in multi-sample VCF format)\n"
text = text + "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t" + smallID + "\t" + largeID + "\n"
outHandle.write(text)

inHandle = open(largeVCF)
line = inHandle.readline()
			
totalReads = ""
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	commentFlag = re.search("^#",line)
	
	if not commentFlag:	
		lineInfo = line.split("\t")
		chr = lineInfo[0]
		pos = lineInfo[1]
		varID = lineInfo[2]
		ref = lineInfo[3]
		var = lineInfo[4]
		qual = lineInfo[5]
		flag = lineInfo[6]
		
		genotypeResult = re.search("^GT",lineInfo[8])
		if genotypeResult:
			callText = lineInfo[9]
			callInfo = callText.split(":")
			genotype = callInfo[0]
		else:
			print "Need to extract genotype from different position " + lineInfo[8]
			sys.exit()
				
		largePos = chr + "\t" + pos
		if largePos in smallPosHash:
			largeVarID = chr + "\t" + pos + "\tNA\t" + ref + "\t" + var
			if largeVarID in smallVarHash:
				smallGenotype = smallVarHash[largeVarID]
				
				if genotype == smallGenotype:
					fullRecoveryHash[largeVarID]=genotype
				else:
					partialRecoveryHash[largeVarID]=genotype
			else:
				smallVarText = smallPosHash[largePos]
				smallVarInfo = smallVarText.split("\t")
				
				smallVarID = smallVarInfo[0]
				smallVarRef = smallVarInfo[1]
				smallVar = smallVarInfo[2]
				smallVarFlag = smallVarInfo[3]
				
				if smallVarFlag == "PASS":
					smallVarFlag = "discordant"
				else:
					smallVarFlag = smallVarFlag + ",discordant"
				
				smallVarID2 = largePos + "\tNA\t" + smallVarRef + "\t" + smallVar
				smallGenotype = smallVarHash[smallVarID2]
				discordantHash[smallVarID2]	= largeVarID
				
				text = largePos + "\t" + smallVarID + "\t" + smallVarRef + "\t" + smallVar + "\tNA\t" + smallVarFlag + "\tNA\tGT\t" + smallGenotype + "\t0/0\n"
				outHandle.write(text)
				text = largePos + "\t" + varID + "\t" + ref + "\t" + var + "\t" + qual + "\t" + smallVarFlag + "\tNA\tGT\t0/0\t" +  genotype + "\n"
				outHandle.write(text)
			
	line = inHandle.readline()

#output missing variants and report recovery rate
smallCount = 0
validatedCount = 0

fullValidationCount = len(fullRecoveryHash.keys())
fullRecoveryRate = 100 * float(fullValidationCount)/float(refVarCount)

partialValidationCount = len(partialRecoveryHash.keys())
fullAndPartialRecoveryRate = 100 * float(fullValidationCount + partialValidationCount)/float(refVarCount)

print largeID + " : Matching Allele recovery of " + str(fullValidationCount) + " " + smallID + " variants ( " + '{:.2f}'.format(fullRecoveryRate) + "% full recovery)"
print largeID + " : Matching Genotype recovery of " + str(partialValidationCount) + " " + smallID + " variants ( " + '{:.2f}'.format(fullRecoveryRate) + "% full+partial recovery)"

for smallVarID in smallVarHash:
	if (smallVarID not in fullRecoveryHash) and (smallVarID not in partialRecoveryHash) and (smallVarID not in discordantHash):
		smallGenotype = smallVarHash[smallVarID]
		
		varInfo = smallVarID.split("\t")
		smallChr = varInfo[0]
		smallPos = varInfo[1]
		
		smallPos2 = smallChr + "\t" + smallPos
		smallText = smallPosHash[smallPos2]
		varInfo2 = smallText.split("\t")
				
		smallVarID2 = varInfo2[0]
		smallVarRef = varInfo2[1]
		smallVar = varInfo2[2]
		smallVarFlag = varInfo2[3]
				
		text = smallPos2 + "\t" + smallVarID2 + "\t" + smallVarRef + "\t" + smallVar + "\tNA\t" + smallVarFlag + "\tNA\tGT\t" + smallGenotype + "\t0/0\n"
		outHandle.write(text)		