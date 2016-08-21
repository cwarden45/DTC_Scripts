import sys
import re
import os
from Bio import SeqIO

inputFile = ""
refFile = "../hg19.fasta"
outputFile = "23andMe.vcf"

for arg in sys.argv:
	inResult = re.search("^--23andMe=(.*)",arg)
	refResult = re.search("^--genome_ref=(.*)",arg)
	outputResult = re.search("^--vcf=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if inResult:
		inputFile = inResult.group(1)

	if refResult:
		refFile = refResult.group(1)

	if outputResult:
		outputFile = outputResult.group(1)
		
	if helpResult:
		print "Usage: python 23andMe_to_VCF.py --23andMe=[genome_Name_Version_ID.txt] --genome_ref=../hg19.fasta --vcf=23andMe.vcf\n"
		print "--23andMe : Raw data file from 23andMe\n"
		print "--genome_ref : Genome reference sequences\n"
		print "--vcf : Output VCF file\n"
		sys.exit()
		
if inputFile == "":
	print "Must specify 23andMe raw data file with --23andMe "
	sys.exit()
	
refHash = {}

#from https://www.biostars.org/p/710/
fasta_sequences = SeqIO.parse(open(refFile),'fasta')
for fasta in fasta_sequences:
	chrName = fasta.id
	chrSequence = str(fasta.seq)
	
	suppFlag = re.search("_",chrName)
	if not suppFlag:
		print "Adding " + chrName + " to Ref Hash"
		refHash[chrName] = chrSequence
	
outHandle = open(outputFile, 'w')
text = "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tGenotype\n"
outHandle.write(text)

inHandle = open(inputFile)
line = inHandle.readline()
			
totalReads = ""
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	commentFlag = re.search("^#",line)
	
	if not commentFlag:	
		lineInfo = line.split("\t")
		snpID = lineInfo[0]
		snpChr = "chr" + lineInfo[1]
		if snpChr == "chrMT":
			snpChr = "chrM"
		snpPos = int(lineInfo[2])
		genotype = lineInfo[3]
		
		if (len(genotype) == 2):
			genotype1 = genotype[0:1]
			genotype2 = genotype[1:2]
		
		flag = "PASS"
		
		delFlag = re.search("--",genotype)
		#really, this is "no call" instead of deletion, but I can sort them out later because a flag is added
		if delFlag:
			refChrSeq = refHash[snpChr]
			#subtract 2 to get upstream nucleotide
			hg19_python_index = snpPos - 2
			refString = refChrSeq[hg19_python_index:hg19_python_index+2]
			
			lowerFlag = re.search("[acgt]", refSnp)
			if lowerFlag:
				flag = "repeat,nocall"
				refString = refString.upper()
			else:
				flag = "nocall"
				
			genotype = "1/1"
			varString = refChrSeq[hg19_python_index:hg19_python_index+1]
			text = snpChr + "\t" + str(snpPos-1) + "\t" + snpID + "\t" + refString + "\t" + varString+ "\tNA\t" + flag + "\tNA\tGT\t" + genotype + "\n"
			outHandle.write(text)
		else:
			#alternative deletion ID
			delFlag2 = re.search("D",genotype)
			insFlag = re.search("I",genotype)
			if delFlag2 or insFlag:
				if genotype == "II":
					print "Skipping " + snpID + ", which most likely means no variation from reference (not 2x insertion)"
					#rs28357092, rs62642586, and rs61752903 with "II" represent lack of 1 bp deletion
					#rs140864 and rs61752910 with "II" represent lack of 3 bp deletion
				elif genotype == "I":
					print "Skipping " + snpID + " on " + snpChr
					#rs62635036 has no variant in WGS data
				elif genotype == "DD":
					print "Skipping " + snpID + ", which most likely means no variation from reference (not 2x deletion)"
					#rs63749059 DD means lack of ACAGGTTA insertion, rs61750635 means lack of GAA insertion
					#rs61748513 no longer in dbSNP (and I could find neither position or rsID match in 23andMe raw data browser), but I lack variation at this site
				elif genotype == "D":
					print "Skipping " + snpID + " on " + snpChr
				elif snpID == "rs35569394":
					#ambiguous TCCCACTCTTCCCACAGG / GGTCCCACTCTTCCCACA insertion
					ins ="GGTCCCACTCTTCCCACA"
					if genotype == "DI":
						newPos = 43736416
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+1]
						insString = refString + ins
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs11568822":
					#ambiguous TTGC / GCTT insertion
					#left-aligned in WGS, right-aligned in 23andMe
					if genotype == "DI":
						newPos = 45417638
						refString = "CTT"
						insString = "CTTGCTT"
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs8176719":
					#false positive insertion
					#dbSNP entry has been removed, but I'm calling thia an insertion because no nearby C
					ins ="C"
					if genotype == "DI":
						hg19_python_index = snpPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+1]
						insString = refString + ins
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs16626":
					ins ="GGACTTCACG"
					if genotype == "DI":
						hg19_python_index = snpPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+1]
						insString = refString + ins
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs3216147":
					ins ="C"
					#left-aligned insertion in 23andMe and (most) WGS reads
					if genotype == "DI":
						hg19_python_index = snpPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+1]
						insString = refString + ins
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs1799768":
					#polyG insertion = left-aligned in WGS and 23andMe
					ins ="G"
					if genotype == "DI":
						hg19_python_index = snpPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+1]
						insString = refString + ins
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs1799732":
					#G-adjacent G insertion: left-aligned in NGS, right-aligned in 23andMe (G coordinate, rather than upstream G coordinate)
					ins ="G"
					if genotype == "DI":
						snpPos = 113346251
						refString = "TG"
						insString = "TGG"
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs5789358":
					#polyC insertion
					if genotype == "DI":
						refString = "ACC"
						insString = "ACCC"
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs3217559":
					ins ="G"
					if genotype == "DI":
						hg19_python_index = snpPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+1]
						insString = refString + ins
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs2307981":
					ins ="CAA"
					if genotype == "DI":
						hg19_python_index = snpPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+1]
						insString = refString + ins
						
						genotype = "1/0"
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refString + "\t" + insString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs3834458":
					#unambiguous T deletion 
					if genotype == "DI":
						newPos = snpPos - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs5861422":
					#unambiguous A deletion (position correct in file. bit 23andMe Raw Data portal reports my genotype is -/T, and position in 23andMe portal and dbSNP is off by one)
					if genotype == "DI":
						newPos = snpPos - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs5856807":
					#unambiguous G deletion
					if genotype == "DI":
						newPos = snpPos - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs56909176":
					#unambiguous G deletion
					if genotype == "DI":
						newPos = snpPos - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs3212879":
					#polyG deletion = left-aligned in WGS, right-aligned in 23andMe
					if genotype == "DI":
						newPos = 69463479 - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs11310407":
					#polyG deletion = left-aligned in WGS, right-aligned in 23andMe
					if genotype == "DI":
						newPos = 4389405 - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs3832043":
					#polyT deletion = left-aligned in WGS, right-aligned in 23andMe
					if genotype == "DI":
						newPos = 234580454 - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "i4000313":
					#2bp polyA deletion = left-aligned in WGS, right-aligned in 23andMe
					if genotype == "DI":
						newPos = 117149182 - 1
						hg19_python_index = newPos - 1
						delLength = 2
						refString = refChrSeq[hg19_python_index:(hg19_python_index+1 + delLength)]
						delString = refChrSeq[hg19_python_index:(hg19_python_index+1)]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs35713930":
					#2bp polyA deletion = left-aligned in WGS, right-aligned in dbSNP
					#1bp more common in WGS data, but dbSNP entry is for -AA
					if genotype == "DI":
						newPos = snpPos - 1
						hg19_python_index = newPos - 1
						delLength = 2
						refString = refChrSeq[hg19_python_index:(hg19_python_index+1 + delLength)]
						delString = refChrSeq[hg19_python_index:(hg19_python_index+1)]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs1799750":
					#polyC deletion = left-aligned in WGS and 23andMe
					if genotype == "DI":
						newPos = snpPos - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs72653144":
					#polyG deletion false positive = 23andMe/dbSNP position refers to left-adjacent A
					#figured out type of variant using dbSNP entry
					if genotype == "DI":
						hg19_python_index = snpPos - 1
						homoLength = 5
						delLength = 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+homoLength + delLength]
						delString = refChrSeq[hg19_python_index:hg19_python_index+homoLength]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs11313475":
					#polyA deletion = left-aligned in WGS and 23andMe
					if genotype == "DI":
						newPos = snpPos - 1
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+2]
						delString = refChrSeq[hg19_python_index:hg19_python_index+1]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs3035516":
					#GT repeat, 1x deletion = left-aligned in WGS , (almost) right-aligned in 23andMe
					if genotype == "DI":
						newPos = 22138562 - 1
						hg19_python_index = newPos - 1
						homoLength = 6
						delLength = 2
						refString = refChrSeq[hg19_python_index:hg19_python_index+homoLength + delLength]
						delString = refChrSeq[hg19_python_index:hg19_python_index+homoLength]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs35029493":
					#polyA deletion = left-aligned in WGS , right-aligned in 23andMe
					if genotype == "DI":
						newPos = 27499517 - 1
						hg19_python_index = newPos - 1
						homoLength = 12
						delLength = 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+homoLength + delLength]
						delString = refChrSeq[hg19_python_index:hg19_python_index+homoLength]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs11317573":
					#polyT deletion = left-aligned in WGS , right-aligned in 23andMe
					if genotype == "DI":
						newPos = 40757187 - 1
						hg19_python_index = newPos - 1
						homoLength = 9
						delLength = 1
						refString = refChrSeq[hg19_python_index:hg19_python_index+homoLength + delLength]
						delString = refChrSeq[hg19_python_index:hg19_python_index+homoLength]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "rs2308169":
					#ambiguous CTATG/ATGCT deletion = left-aligned in WGS, right-aligned in 23andMe
					if genotype == "DI":
						newPos = 12087103 - 1
						delLength = 5
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:(hg19_python_index+1 + delLength)]
						delString = refChrSeq[hg19_python_index:(hg19_python_index+1)]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				elif snpID == "i4990308":
					#ambiguous TC/CT deletion = left-aligned in WGS and 23andMe (not in dbSNP)
					if genotype == "DI":
						newPos = snpPos - 1
						delLength = 2
						hg19_python_index = newPos - 1
						refString = refChrSeq[hg19_python_index:(hg19_python_index+1 + delLength)]
						delString = refChrSeq[hg19_python_index:(hg19_python_index+1)]
						
						genotype = "1/0"
						text = snpChr + "\t" + str(newPos) + "\t" + snpID + "\t" + refString + "\t" + delString + "\tNA\tDI\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
					else:
						print line
						print "Need to define allele for " + snpID
						sys.exit()
				else:
					print "Need to map " + line
					sys.exit()
			else:
				refChrSeq = refHash[snpChr]
				hg19_python_index = snpPos - 1
				refSnp = refChrSeq[hg19_python_index:hg19_python_index+1]
				
				lowerFlag = re.search("[acgt]", refSnp)
				if lowerFlag:
					flag = "repeat"
					refSnp = refSnp.upper()

				if (len(genotype) == 1):
					if genotype != refSnp:
						alt = genotype
						genotype = "1"
					else:
						alt = refSnp
						genotype = "0"
							
					text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refSnp + "\t" + alt + "\tNA\t" + flag + "\tNA\tGT\t" + genotype + "\n"
					outHandle.write(text)
				else:
					if genotype1 != genotype2:
						varAllele = ""
						varCount = 0
						
						if genotype1 != refSnp:
							varCount += 1
							varAllele = genotype1

						if genotype2 != refSnp:
							varCount += 1
							varAllele = genotype2				
						
						if varCount == 1:
							genotype = "0/1"			
							text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refSnp + "\t" + varAllele + "\tNA\t" + flag + "\tNA\tGT\t" + genotype + "\n"
							outHandle.write(text)
						elif varCount == 2:
							varAllele = genotype1 + "," + genotype2
							genotype = "1/2"
							text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refSnp + "\t" + varAllele + "\tNA\t" + flag + "\tNA\tGT\t" + genotype + "\n"
							outHandle.write(text)
						elif varCount == 0:
							print "Check " + line
							print "Supposedly two alleles without variation from reference"
							sys.exit()
					else:
						genotype = "0/0"
						alt = refSnp
						if genotype1 != refSnp:
							alt = genotype1
							genotype = "1/1"
							
						text = snpChr + "\t" + str(snpPos) + "\t" + snpID + "\t" + refSnp + "\t" + alt + "\tNA\t" + flag + "\tNA\tGT\t" + genotype + "\n"
						outHandle.write(text)
			
	line = inHandle.readline()