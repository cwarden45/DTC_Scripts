import sys
import re
import os
import subprocess

parameterFile = "parameters.txt"

#be careful with use of finished sample array : if you do skip re-processing some samples, be sure to wait for running final genotype (without any skipped files, and removing hold requirement for qsub)
finishedSamples = ()

java = "/net/isi-dcnl/ifs/user_data/Seq/jre1.8.0_121/bin/java"
jar_path = "/net/isi-dcnl/ifs/user_data/Seq/"

java_mem = ""
fa_ref = ""
alignmentFolder = ""
targetBED = ""
email = ""

inHandle = open(parameterFile)
lines = inHandle.readlines()
			
for line in lines:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	param = lineInfo[0]
	value = lineInfo[1]

	if param == "strand":
		strand = value
	
	if param == "Alignment_Folder":
		alignmentFolder = value
		
	if param == "BWA_Ref":
		fa_ref = value

	if param == "target_bed":
		targetBED = value
		
	if param == "MEM_Limit":
		java_mem = value

	if param == "Cluster_Email":
		email = value
		
if (java_mem == "") or (java_mem == "[required]"):
	print "Need to enter a value for 'MEM_Limit'!"
	sys.exit()

if (fa_ref == "") or (fa_ref == "[required]"):
	print "Need to enter a value for 'BWA_Ref'!"
	sys.exit()
	
if (targetBED == "") or (targetBED == "[required]"):
	print "Need to enter a value for 'target_bed'!"
	sys.exit()
	
if (alignmentFolder == "") or (alignmentFolder == "[required]"):
	print "Need to enter a value for 'Alignment_Folder'!"
	sys.exit()

if (email == "") or (email == "[required]"):
	print "Need to enter a value for 'Cluster_Email'!"
	sys.exit()
	
fileResults = os.listdir(alignmentFolder)

combinedFiles = ""

jobCount = 0
for file in fileResults:
	result = re.search("(.*).nodup.bam$",file)
	
	if result:
		sample = result.group(1)
		
		if (sample not in finishedSamples):
			jobCount += 1
			print sample
			shellScript = "joint_GATK_" + sample + ".sh"
			outHandle = open(shellScript, "w")
			text = "#!/bin/bash\n"
			text = text + "#$ -M "+email+"\n"
			text = text + "#$ -m bea\n"
			text = text + "#$ -N jGATK"+str(jobCount)+"\n"
			text = text + "#$ -q single.q\n"
			text = text + "#$ -l vf="+re.sub("g","G",java_mem)+"\n"
			text = text + "#$ -j yes\n"
			text = text + "#$ -o jGATK"+str(jobCount)+".log\n"
			text = text + "#$ -cwd\n"
			text = text + "#$ -V\n"
			outHandle.write(text)

			filteredBam = alignmentFolder + "/" + file
			
			outputSubfolder = alignmentFolder +"/" + sample
			
			targetBam = alignmentFolder +"/" + sample + "/target.bam"
			#use full overlap variant filter with "-f 1", but allow partial read coverage
			text = "bedtools intersect -a " + filteredBam + " -b " + targetBED + " > " + targetBam + "\n"
			outHandle.write(text)			

			text = "samtools index " + targetBam + "\n"
			outHandle.write(text)
			
			fullVCF = outputSubfolder + "/" + sample + ".GATK.HC.g.vcf"
			combinedFiles = combinedFiles + " --variant " + fullVCF
			text = java + " -Xmx" + java_mem + " -jar "+jar_path+"GenomeAnalysisTK-3.7.jar -T HaplotypeCaller -R " + fa_ref + " -I " + targetBam + " -o " + fullVCF + " -dontUseSoftClippedBases -stand_call_conf 20.0 --emitRefConfidence GVCF -G Standard -G AS_Standard\n"
			outHandle.write(text)
			
			text = "rm " + targetBam + "\n"
			outHandle.write(text)	
			outHandle.close()			

shellScript = "joint_GATK_call.sh"
outHandle = open(shellScript, "w")
text = "#!/bin/bash\n"
text = text + "#$ -hold_jid "
for i in xrange(1,jobCount+1):
	if i == 1:
		text = text + "jGATK"+str(i)
	else:
		text = text + ",jGATK"+str(i)
text = text + "\n"
text = text + "#$ -M "+email+"\n"
text = text + "#$ -m bea\n"
text = text + "#$ -N jGATKcall\n"
text = text + "#$ -q single.q\n"
text = text + "#$ -l vf="+re.sub("g","G",java_mem)+"\n"
text = text + "#$ -j yes\n"
text = text + "#$ -o jGATKcall.log\n"
text = text + "#$ -cwd\n"
text = text + "#$ -V\n"
outHandle.write(text)
			
combinedVCF = "joint_variant_calls.GATK.HC.all.vcf"																			
text = java + " -Xmx" + java_mem + " -jar "+jar_path+"GenomeAnalysisTK-3.7.jar -T GenotypeGVCFs -R " + fa_ref + combinedFiles + " -o " + combinedVCF + "\n"
outHandle.write(text)
			
#QD = quality score / depth
#so, QD > 2.0 is not a very strict filter
bpFilteredVCF = "joint_variant_calls.GATK.HC.flagged.vcf"																			
text = java + " -Xmx" + java_mem + " -jar "+jar_path+"GenomeAnalysisTK-3.7.jar -T VariantFiltration -R " + fa_ref + " -V " + combinedVCF + " -o " + bpFilteredVCF + " -window 35 -cluster 3 -filterName QC -filter \"QD < 2.0\" -filterName FS -filter \"FS > 30.0\"\n"
outHandle.write(text)