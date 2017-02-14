import sys
import re
import os
import subprocess

finishedSamples = []
parameterFile = "parameters.txt"

threads = ""
email = ""
readsFolder = ""
bwaRef = ""
bwaAlignmentFolder = ""
pairedStatus = ""
targetInterval = ""
memLimit = ""

inHandle = open(parameterFile)
lines = inHandle.readlines()
			
for line in lines:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	param = lineInfo[0]
	value = lineInfo[1]

	if param == "Reads_Folder":
		readsFolder = value

	if param == "Threads":
		threads = value
		
	if param == "Cluster_Email":
		email = value

	if param == "BWA_Ref":
		bwaRef = value

	if param == "Alignment_Folder":
		bwaAlignmentFolder = value
		
	if param == "PE_Reads":
		pairedStatus = value

	if param == "MEM_Limit":
		memLimit = value
		
	if param == "target_regions":
		targetInterval = value

if (memLimit == "") or (memLimit == "[required]"):
	print "Need to enter a value for 'MEM_Limit'!"
	sys.exit()
		
if (targetInterval == "") or (targetInterval == "[required]"):
	print "Need to enter a value for 'target_regions'!"
	sys.exit()
		
if (readsFolder == "") or (readsFolder == "[required]"):
	print "Need to enter a value for 'Reads_Folder'!"
	sys.exit()

if (threads == "") or (threads == "[required]"):
	print "Need to enter a value for 'Threads'!"
	sys.exit()
	
if (bwaAlignmentFolder == "") or (bwaAlignmentFolder == "[required]"):
	print "Need to enter a value for 'Alignment_Folder'!"
	sys.exit()
	
if (bwaRef == "") or (bwaRef == "[required]"):
	print "Need to enter a value for 'BWA_Ref'!"
	sys.exit()
	
if (email == "") or (email == "[required]"):
	print "Need to enter a value for 'Cluster_Email'!"
	sys.exit()
	
if (pairedStatus == "") or (pairedStatus == "[required]"):
	print "Need to enter a value for 'PE_Reads'!"
	sys.exit()

submitAll = "master_BWA_queue.sh"
masterHandle = open(submitAll,"w")
text = "#!/bin/bash\n"
masterHandle.write(text)
	
fileResults = os.listdir(readsFolder)

jobCount = 0
for file in fileResults:
	result = re.search("(.*)_(\w{6})_L\d{3}_R1_001.fastq$",file)
	
	if result:
		sample = result.group(1)
		barcode = result.group(2)
		
		jobCount += 1
		
		if (sample not in finishedSamples):
			print sample
			shellScript = sample + ".sh"
			text = "qsub " + shellScript + "\n"
			masterHandle.write(text)
			
			outHandle = open(shellScript, "w")
			text = "#!/bin/bash\n"
			text = text + "#$ -M "+email+"\n"
			text = text + "#$ -m bea\n"
			text = text + "#$ -N DNAbwa"+str(jobCount)+"\n"
			text = text + "#$ -q all.q\n"
			text = text + "#$ -pe shared "+str(threads)+"\n"
			text = text + "#$ -l vf="+memLimit+"\n"
			text = text + "#$ -j yes\n"
			text = text + "#$ -o DNAbwa"+str(jobCount)+".log\n"
			text = text + "#$ -cwd\n"
			text = text + "#$ -V\n"
			outHandle.write(text)
			
			sampleSubfolder = bwaAlignmentFolder + "/" + sample
			text = "mkdir " + sampleSubfolder + "\n"
			outHandle.write(text)
									
			if (pairedStatus == "yes"):
				read1 = readsFolder + "/" + file
				read2 = re.sub("_R1_001.fastq$","_R2_001.fastq",read1)
			
				alnSam = sampleSubfolder + "/aligned.sam"
				text = "bwa mem -t "+ str(threads) + " " + bwaRef + " " + read1 + " " + read2  + " > " + alnSam + "\n"
				outHandle.write(text)			
			elif(pairedStatus == "no"):
				read1 = readsFolder + "/" + file
			
				alnSam = sampleSubfolder + "/aligned.sam"
				text = "bwa mem -t "+ str(threads) + " " + bwaRef + " " + read1 + " > " + alnSam + "\n"
				outHandle.write(text)
			else:
				print "'PE_Reads' value must be 'yes' or 'no'"
				sys.exit()

			alnBam = sampleSubfolder + "/aligned.bam"
			text = "samtools view -bS " + alnSam + " > " + alnBam + "\n"
			outHandle.write(text)

			text = "rm " + alnSam + "\n"
			outHandle.write(text)
			
			rgBam = sampleSubfolder + "/rg.bam"
			text = "java -Xmx" + memLimit + " -jar /opt/picard-tools-1.72/AddOrReplaceReadGroups.jar I=" + alnBam + " O=" + rgBam + " SO=coordinate RGID=1 RGLB=Exome-Seq RGPL=Illumina RGPU="+barcode+" RGCN=COH RGSM=" + sample + "\n"
			outHandle.write(text)

			text = "rm " + alnBam + "\n"
			outHandle.write(text)
			
			statsFile = sampleSubfolder + "/alignment_stats.txt"
			text = "samtools flagstat " + rgBam + " > " + statsFile + "\n"
			outHandle.write(text)

			duplicateMetrics = sampleSubfolder + "/MarkDuplicates_metrics.txt"
			filteredBam = bwaAlignmentFolder + "/" + sample + ".nodup.bam"
			text = "java -Xmx" + memLimit + " -jar /opt/picard-tools-1.72/MarkDuplicates.jar I=" + rgBam + " O=" + filteredBam + " M=" + duplicateMetrics+" REMOVE_DUPLICATES=true CREATE_INDEX=true\n"
			outHandle.write(text)
			
			text = "rm " + rgBam + "\n"
			outHandle.write(text)

			statFile = sampleSubfolder + "/idxstats_no_dup.txt"
			text = "samtools idxstats " + filteredBam + " > " + statFile + "\n"
			outHandle.write(text)			
	
			targetMetrics = sampleSubfolder + "/HsMetrics_coverage_stats_no_dup.txt"
			targetMetrics2 = sampleSubfolder + "/HsMetrics_coverage_stats_per_target_no_dup.txt"
			text = "java -Xmx" + memLimit + " -jar /opt/picard-tools-1.72/CalculateHsMetrics.jar I=" + filteredBam + " O=" + targetMetrics + " PER_TARGET_COVERAGE=" + targetMetrics2 + " R=" + bwaRef + " BAIT_INTERVALS=" + targetInterval + " TARGET_INTERVALS=" + targetInterval + "\n"
			outHandle.write(text)
			
			if (pairedStatus == "yes"):
				text = "gzip "+ read1 +"\n"
				outHandle.write(text)
			
				text = "gzip "+ read2 +"\n"
				outHandle.write(text)			
			elif(pairedStatus == "no"):
				text = "gzip "+ read1 +"\n"
				outHandle.write(text)
