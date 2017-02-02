import sys
import re
import os
import subprocess

parameterFile = "parameters.txt"
statFile = "coverage_statistics.txt"

readsFolder = ""
bwaAlignmentFolder = ""

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

	if param == "Alignment_Folder":
		bwaAlignmentFolder = value
		
if (readsFolder == "") or (readsFolder == "[required]"):
	print "Need to enter a value for 'Reads_Folder'!"
	sys.exit()
	
if (bwaAlignmentFolder == "") or (bwaAlignmentFolder == "[required]"):
	print "Need to enter a value for 'Alignment_Folder'!"
	sys.exit()


statHandle = open(statFile,"w")
text = "SampleID\tSeqID\tuserID\tTotalReads\tPercent.Aligned\tPercent.Duplicate\tPercent.OnTarget\tAverage.Cov\tPercent.10x\tPercent.20x\tPercent.30x\n"
statHandle.write(text)
	
fastqcFolder = readsFolder + "/QC"
fileResults = os.listdir(readsFolder)

for file in fileResults:
	result = re.search("(.*)_\w{6}_L\d{3}_R1_001.fastq.gz$",file)
	
	if result:
		sample = result.group(1)
		print sample
		
		r2 = re.search("^(\d+)_.*",sample)
		seqID = r2.group(1)
		
		shortID = re.sub(seqID + "_","",sample)
		
		#get total reads from FastQC
		fastqcPrefix = re.sub(".fastq.gz","",file)
		fastQCtext = zipReport = fastqcFolder + "/" + fastqcPrefix + "_fastqc/fastqc_data.txt"
		
		inHandle = open(fastQCtext)
		line = inHandle.readline()
		
		lineCount = 0
		
		while line:
			line = re.sub("\n","",line)
			line = re.sub("\r","",line)
			
			lineCount += 1
			
			if lineCount == 7:
				
				totalResult = re.search("Total Sequences\t(\d+)",line)
				if totalResult:
					totalReads = totalResult.group(1)
				else:
					print "Problem parsing FastQC file!\n"
					sys.exit()
			
			line = inHandle.readline()
		
		inHandle.close()
		
		#get alignment stats from samtools flagstat
		sampleSubfolder = bwaAlignmentFolder + "/" + sample
		flagstatFile = sampleSubfolder + "/alignment_stats.txt"

		inHandle = open(flagstatFile)
		line = inHandle.readline()
		
		lineCount = 0
		
		while line:
			line = re.sub("\n","",line)
			line = re.sub("\r","",line)
			
			lineCount += 1
			
			if lineCount == 3:
				
				alignedResult = re.search("\((\d+\.\d+%):",line)
				if alignedResult:
					alignedReads = alignedResult.group(1)
				else:
					print "Problem parsing samtools flagstat file!\n"
					sys.exit()
				
			line = inHandle.readline()
		
		inHandle.close()
		
		#get duplicate rate from Picard MarkDuplicates
		duplicateMetrics = sampleSubfolder + "/MarkDuplicates_metrics.txt"

		inHandle = open(duplicateMetrics)
		line = inHandle.readline()
		
		lineCount = 0
		
		while line:
			line = re.sub("\n","",line)
			line = re.sub("\r","",line)
			
			lineCount += 1
			
			if lineCount == 8:
				lineInfo = line.split("\t")
				
				percentDuplicate = 100*float(lineInfo[7])
				percentDuplicate =  '{0:.2f}'.format(percentDuplicate) + "%"
				
			line = inHandle.readline()
		
		inHandle.close()
		
		#get coverage stats from Picard HsMetrics (could also use for total reads)
		hsMetrics = sampleSubfolder + "/HsMetrics_coverage_stats_no_dup.txt"
		#hsMetrics2 = sampleSubfolder + "/HsMetrics_coverage_stats_per_target_no_dup.txt"

		inHandle = open(hsMetrics)
		line = inHandle.readline()
		
		lineCount = 0
		
		while line:
			line = re.sub("\n","",line)
			line = re.sub("\r","",line)
			
			lineCount += 1
			
			if lineCount == 8:
				lineInfo = line.split("\t")
				
				percentOnTarget = 100 * float(lineInfo[17])
				percentOnTarget =  '{0:.2f}'.format(percentOnTarget) + "%"
				
				avgCov = float(lineInfo[21])
				avgCov =  '{0:.2f}'.format(avgCov) + "x"
				
				Percent10x = 100 * float(lineInfo[28])
				Percent10x = '{0:.4f}'.format(Percent10x) + "%"
				
				#you'll need to use a later version to get 40x/100x metrics
				Percent20x = 100 * float(lineInfo[29])
				Percent20x = '{0:.4f}'.format(Percent20x) + "%"
				
				Percent30x = 100 * float(lineInfo[30])
				Percent30x = '{0:.4f}'.format(Percent30x) + "%"
			line = inHandle.readline()
		
		inHandle.close()
		
		text = sample + "\t" + seqID + "\t" + shortID + "\t" + totalReads + "\t" + alignedReads + "\t" + percentDuplicate + "\t" + percentOnTarget+ "\t" + avgCov + "\t" + Percent10x + "\t" + Percent20x + "\t" + Percent30x + "\n"
		statHandle.write(text)
