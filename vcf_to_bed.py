import sys
import re
import os

vcf = ""
caller = "Veritas"

for arg in sys.argv:
	vcfResult = re.search("^--vcf=(.*)",arg)
	callerResult = re.search("^--caller=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if vcfResult:
		vcf = vcfResult.group(1)

	if callerResult:
		caller = callerResult.group(1)
		
	if helpResult:
		print "Usage: python vcf_to_bed.py --vcf=file.vcf --caller=Veritas\n"
		print "--vcf : Name of vcf containing deletions, duplications, and/or insertions\n"
		print "--caller : Variant Caller used to produce .vcf file\n\tCan be 'Veritas','LUMPY','DELLY_DEL','DELLY_DUP',or'DELLY_INS'\n"
		sys.exit()
		
if caller == "Veritas":
	delFile = "Veritas_DEL.bed"
	delHandle = open(delFile, "w")
	
	insFile = "Veritas_INS.bed"
	insHandle = open(insFile, "w")
	
	inHandle = open(vcf)
	line = inHandle.readline()

	while line:	
		line = re.sub("\n","",line)
		line = re.sub("\r","",line)
		
		result = re.search("^#",line)
		
		if not result:
			lineInfo = line.split("\t")
			chr = lineInfo[0]
			pos = lineInfo[1]
			ref = lineInfo[3]
			var = lineInfo[4]
			qual = lineInfo[5]
			flag = lineInfo[6]
			
			polyFlag = re.search(",",var)
			
			if polyFlag:
				varInfo = var.split(",")
				var1 = varInfo[0]
				var2 = varInfo[1]

				if ((len(ref) > 1) or (len(var1) > 1)) and (flag == "PASS"):
					if len(ref) > len(var1):
						#deletion
						varStop = int(pos) + len(ref) - 1
						diff = len(ref) - len(var1)
						text = chr + "\t" + pos + "\t" + str(varStop) + "\t" + ref + ":" + var1 + "\t" + str(diff) + "\n"
						delHandle.write(text)
					elif len(var1) > len(ref):
						#dup/ins
						varStop = int(pos) + len(ref) - 1
						diff = len(var1) - len(ref)
						text = chr + "\t" + pos + "\t" + str(varStop) + "\t" + ref + ":" + var1 + "\t" + str(diff) + "\n"
						insHandle.write(text)

				if ((len(ref) > 1) or (len(var2) > 1)) and (flag == "PASS"):
					if len(ref) > len(var2):
						#deletion
						varStop = int(pos) + len(ref) - 1
						diff = len(ref) - len(var2)
						text = chr + "\t" + pos + "\t" + str(varStop) + "\t" + ref + ":" + var2 + "\t" + str(diff) + "\n"
						delHandle.write(text)
					elif len(var2) > len(ref):
						#dup/ins
						varStop = int(pos) + len(ref) - 1
						diff = len(var2) - len(ref)
						text = chr + "\t" + pos + "\t" + str(varStop) + "\t" + ref + ":" + var2 + "\t" + str(diff) + "\n"
						insHandle.write(text)
						
			else:
				if ((len(ref) > 1) or (len(var) > 1)) and (flag == "PASS"):
					if len(ref) > len(var):
						#deletion
						varStop = int(pos) + len(ref) - 1
						diff = len(ref) - len(var)
						text = chr + "\t" + pos + "\t" + str(varStop) + "\t" + ref + ":" + var + "\t" + str(diff) + "\n"
						delHandle.write(text)
					elif len(var) > len(ref):
						#dup/ins
						varStop = int(pos) + len(ref) - 1
						diff = len(var) - len(ref)
						text = chr + "\t" + pos + "\t" + str(varStop) + "\t" + ref + ":" + var + "\t" + str(diff) + "\n"
						insHandle.write(text)
		line = inHandle.readline()
		
	command = "Rscript indel_hist.R " + delFile + " " + caller
	os.system(command)
	command = "Rscript indel_hist.R " + insFile + " " + caller
	os.system(command)
elif (caller == "LUMPY"):
	delFile = "LUMPY_DEL.bed"
	delHandle = open(delFile, "w")
	
	insFile = "LUMPY_DUP_INS.bed"
	insHandle = open(insFile, "w")
	
	inHandle = open(vcf)
	line = inHandle.readline()

	while line:	
		line = re.sub("\n","",line)
		line = re.sub("\r","",line)
		
		result = re.search("^#",line)
		
		if not result:
			lineInfo = line.split("\t")
			chr1 = lineInfo[0]
			pos1 = lineInfo[1]
			varID = lineInfo[2]
			pos2 = ""
			insLength = ""
			varType = lineInfo[4]
			varType = re.sub(">","",varType)
			varType = re.sub("<","",varType)
			annText = lineInfo[7]
			varID = varType + ":" + varID
			
			if varType == "INS":
				print line
				sys.exit()
			if (varType == "DEL") or (varType == "DUP") or (varType == "DUP:TANDEM"):
				annInfo = annText.split(";")
				for ann in annInfo:
					pos2result = re.search("^END=(.*)",ann)
					
					if pos2result:
						pos2 = pos2result.group(1)
					
				start = min(int(pos1),int(pos2))
				end = max(int(pos1),int(pos2))
				diff = end - start
					
				text = chr1 + "\t" + str(start) + "\t" + str(end) + "\t" + varID + "\t" + str(diff) + "\n"
				
				if (varType == "DEL"):
					delHandle.write(text)
				if (varType == "DUP") or (varType == "DUP:TANDEM"):
					insHandle.write(text)
		line = inHandle.readline()
	
	delHandle.close()
	insHandle.close()
	
	command = "Rscript indel_hist.R " + delFile + " " + caller
	os.system(command)
	command = "Rscript indel_hist.R " + insFile + " " + caller
	os.system(command)
elif (caller == "DELLY_DEL") or (caller == "DELLY_DUP") or (caller == "DELLY_INS"):
	bed = caller + ".bed"
	outHandle = open(bed, "w")
	
	inHandle = open(vcf)
	line = inHandle.readline()

	while line:	
		line = re.sub("\n","",line)
		line = re.sub("\r","",line)
		
		result = re.search("^#",line)
		
		if not result:
			lineInfo = line.split("\t")
			chr1 = lineInfo[0]
			pos1 = lineInfo[1]
			varID = lineInfo[2]
			chr2 = ""
			pos2 = ""
			insLength = ""
			flag = lineInfo[6]
			annText = lineInfo[7]
			annInfo = annText.split(";")
			for ann in annInfo:
				chr2result = re.search("^CHR2=(.*)",ann)
				pos2result = re.search("^END=(.*)",ann)
				insLengthResult = re.search("^INSLEN=(.*)",ann)
				
				if chr2result:
					chr2 = chr2result.group(1)

				if pos2result:
					pos2 = pos2result.group(1)
					
				if insLengthResult:
					insLength = insLengthResult.group(1)
					
			if chr1 != chr2:
				print "Skipping variant in line: " + line
			else:
				start = min(int(pos1),int(pos2))
				end = max(int(pos1),int(pos2))
				if (caller == "DELLY_DEL") or (caller == "DELLY_DUP"):
					diff = end - start
				else:
					diff = insLength
				
				text = chr1 + "\t" + str(start) + "\t" + str(end) + "\t" + varID + "\t" + str(diff) + "\n"
				outHandle.write(text)
		line = inHandle.readline()
		
	command = "Rscript indel_hist.R " + bed + " " + caller
	os.system(command)
else:
	print "--caller must be set to 'Veritas','LUMPY','DELLY_DEL','DELLY_DUP',or'DELLY_INS'"