import sys
import re
import os

vcf1 = "BWA_MEM_Alignment/hg19.gatk.varscan.combined.vcf"
caller1 = "VarScan"
vcf2 = "BWA_MEM_Alignment/hg19.gatk.GATK.HC.vcf"
caller2 = "GATK"
chr20_merged_table= "BWA_MEM_Alignment/chr20_varscan_plus_GATK-HC.txt"

#uncomment code to create merged VarScan .vcf
varscanSNP = "BWA_MEM_Alignment/hg19.gatk.varscan.snp.vcf"
varscanIndel = "BWA_MEM_Alignment/hg19.gatk.varscan.indel.vcf"
command = "bgzip -c " + varscanSNP + " > " + varscanSNP + ".gz"
#os.system(command)
command = "/opt/bcftools/bcftools index " + varscanSNP+ ".gz"
#os.system(command)
command = "bgzip -c " + varscanIndel + " > " + varscanIndel + ".gz"
#os.system(command)
command = "/opt/bcftools/bcftools index " + varscanIndel + ".gz"
#os.system(command)
command = "/opt/bcftools/bcftools concat -a " + varscanSNP + ".gz " + varscanIndel + ".gz > " + vcf1
#os.system(command)

def parseVCF(vcf, caller):
	print "Working on " + caller + " variants"
	hash = {}

	inHandle = open(vcf)
	line = inHandle.readline()
				
	totalReads = ""
				
	while line:
		line = re.sub("\n","",line)
		line = re.sub("\r","",line)
		
		lineInfo = line.split("\t")
		commentResult = re.search("^#",line)
		
		if not commentResult:
			chr = lineInfo[0]
			pos = lineInfo[1]
			ref = lineInfo[3]
			var = lineInfo[4]
			flag = lineInfo[6]
			
			if (chr == "chr20"):
				varID = chr + "\t" + pos + "\t" + ref + "\t" + var
				
				if caller == "VarScan":
					if (flag == "PASS"):
						infoKeyText = lineInfo[8]
						infoText = lineInfo[9]
						
						infoKey = infoKeyText.split(":")
						infoArr = infoText.split(":")
						
						dp = 0
						ad = 0
						
						for i in range(0,len(infoArr)):
							if infoKey[i] == "DP":
								dp = int(infoArr[i])
							if infoKey[i] == "AD":
								ad = int(infoArr[i])
						freq = 100 * float(ad)/float(dp)
						hash[varID] =  "{0:.2f}".format(freq) + "\t" + str(dp)
				elif caller == "GATK":
					infoKeyText = lineInfo[8]
					infoText = lineInfo[9]
					
					infoKey = infoKeyText.split(":")
					infoArr = infoText.split(":")
					
					dp = 0
					ad = 0
					
					for i in range(0,len(infoArr)):
						if infoKey[i] == "DP":
							dp = int(infoArr[i])
						if infoKey[i] == "AD":
							adText = infoArr[i]
							varsCov = adText.split(",")
							ad = int(varsCov[1])
					if (int(dp) != 0) and (int(ad) != 0):
						#some variants lack AD and/or DP values, so I annotate those with question marks
						freq = 100 * float(ad)/float(dp)
						hash[varID] =  "{0:.2f}".format(freq) + "\t" + str(dp)
					else:
						hash[varID] =  "?\t?"
				else:
					print "write code for " + caller
					print line
					sys.exit()
					
		line = inHandle.readline()	
	inHandle.close()
	
	return hash

hash1 = {}
hash2 = {}

#parse vcf1
hash1 = parseVCF(vcf1, caller1)
	
#parse vcf2
hash2 = parseVCF(vcf2, caller2)

#output union with allele frequencies
outHandle = open(chr20_merged_table,"w")
text = "Chr\tPos\tRef\tVar\t" + caller1 + ".Allele.Freq\t"+ caller1 + ".Cov\t" + caller2 + ".Allele.Freq\t" + caller2 + ".Cov\n"
outHandle.write(text)

commonIDs = {}
for varID in hash1:
	commonIDs[varID]=1
for varID in hash2:
	commonIDs[varID]=1
	
for varID in commonIDs:
	caller1_freq = "NA\tNA"
	caller2_freq = "NA\tNA"
	
	if varID in hash1:
		caller1_freq = hash1[varID]

	if varID in hash2:
		caller2_freq = hash2[varID]
		
	text = varID + "\t" + caller1_freq + "\t" + caller2_freq + "\n"
	outHandle.write(text)
		
outHandle.close()