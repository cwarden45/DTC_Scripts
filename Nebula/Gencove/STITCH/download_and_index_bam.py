import sys
import re
import os

inputfile = "BAM_download-test.csv"

inHandle = open(inputfile)
line = inHandle.readline()

lineCount =0
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineCount += 1
	
	if lineCount > 1:
		lineInfo = line.split(",")
		runID = lineInfo[0]
		subjectID = lineInfo[4]
		bamLink = lineInfo[5]
	
		newBam = subjectID + "_" + runID + ".bam"
		if not os.path.exists(newBam):
			command = "wget -O " + newBam + " " + bamLink
			os.system(command)
			
			downloadedBam = os.path.basename(bamLink)
			downloadedBam = re.sub("%","#",downloadedBam)
			print downloadedBam + " --> " + newBam

			command = "mv " + downloadedBam + " " + newBam
			#os.system(command)
			
			command = "samtools index " + newBam
			os.system(command)
		
	line = inHandle.readline()
	
inHandle.close()