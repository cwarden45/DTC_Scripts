import sys
import re
import os

pairingFile = "tumor_pairs.txt"

fa_ref="/path/to/ref.fa"
java = "/path/to/jre1.8.0_121/bin/java"
targetBED="/path/to/Target_Covered.bed"
GATK_jar = "/net/isi-dcnl/ifs/user_data/Seq/GenomeAnalysisTK-3.7.jar"
java_mem = "16g"
email=""

inHandle = open(pairingFile)
lines = inHandle.readlines()

lineCount = 0

for line in lines:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineCount = lineCount + 1
	
	if lineCount > 1:
		lineInfo = line.split("\t")
		mutectPrefix = lineInfo[0]
		tumorBam = lineInfo[1]
		normalBam = lineInfo[2]

		shellScript = "run_MuTect_" + mutectPrefix + ".sh"
		outHandle = open(shellScript, "w")
		text = "#!/bin/bash\n"
		text = text + "#$ -M "+email+"\n"
		text = text + "#$ -m bea\n"
		text = text + "#$ -N MuTect"+str(lineCount)+"\n"
		text = text + "#$ -q single.q\n"
		text = text + "#$ -l vf="+re.sub("g","G",java_mem)+"\n"
		text = text + "#$ -j yes\n"
		text = text + "#$ -o MuTect"+str(lineCount)+".log\n"
		text = text + "#$ -cwd\n"
		text = text + "#$ -V\n"
		outHandle.write(text)

		targetBamN = mutectPrefix +"_targetN.bam"
		#use full overlap variant filter with "-f 1", but allow partial read coverage
		text = "bedtools intersect -a " + normalBam + " -b " + targetBED + " > " + targetBamN + "\n"
		outHandle.write(text)	

		text = "samtools index " + targetBamN + "\n"
		outHandle.write(text)			
		
		targetBamT = mutectPrefix +"_targetT.bam"
		#use full overlap variant filter with "-f 1", but allow partial read coverage
		text = "bedtools intersect -a " + tumorBam + " -b " + targetBED + " > " + targetBamT + "\n"
		outHandle.write(text)	

		text = "samtools index " + targetBamT + "\n"
		outHandle.write(text)	
		
		vcf = mutectPrefix + ".mutect2.vcf"
		text = java + " -Xmx" + java_mem + " -jar "+GATK_jar+" -T MuTect2 -R " + fa_ref + " -I:normal " + targetBamN + " -I:tumor " + targetBamT + " -o " + vcf + " -dontUseSoftClippedBases -stand_call_conf 20.0\n"
		outHandle.write(text)
		
		text = "rm " + targetBamN + "\n"
		outHandle.write(text)

		text = "rm " + targetBamN + ".bai\n"
		outHandle.write(text)
		
		text = "rm " + targetBamT + "\n"
		outHandle.write(text)
		
		text = "rm " + targetBamT + ".bai\n"
		outHandle.write(text)