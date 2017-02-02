import sys
import re
import os
import subprocess
from Bio.Seq import Seq

parameterFile = "parameters.txt"
finishedSamples = ()
threads = 1

readsFolder = ""
email = ""

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

	if param == "Cluster_Email":
		email = value

if (readsFolder == "") or (readsFolder == "[required]"):
	print "Need to enter a value for 'Reads_Folder'!"
	sys.exit()
	
if (email == "") or (email == "[required]"):
	print "Need to enter a value for 'Cluster_Email'!"
	sys.exit()

fastqcFolder = readsFolder + "/QC"
command = "mkdir " + fastqcFolder
os.system(command)
	
fileResults = os.listdir(readsFolder)

submitAll = "master_FastQC_queue.sh"
masterHandle = open(submitAll,"w")
text = "#!/bin/bash\n"
masterHandle.write(text)

jobCount = 0
for file in fileResults:
	result = re.search("(.*)_\w{6}_L\d{3}_R\d_001.fastq$",file)
	
	if result:
		sample = result.group(1)
		jobCount += 1
		
		if (sample not in finishedSamples):
			print sample
			shellScript = "FastQC_"+sample + ".sh"
			text = "qsub " + shellScript + "\n"
			masterHandle.write(text)

			outHandle = open(shellScript, "w")
			text = "#!/bin/bash\n"
			text = text + "#$ -M "+email+"\n"
			text = text + "#$ -m bea\n"
			text = text + "#$ -N DNAfq"+str(jobCount)+"\n"
			text = text + "#$ -q short.q\n"
			text = text + "#$ -pe shared "+str(threads)+"\n"
			text = text + "#$ -l vf=4G\n"
			text = text + "#$ -j yes\n"
			text = text + "#$ -o DNAfq"+str(jobCount)+".log\n"
			text = text + "#$ -cwd\n"
			text = text + "#$ -V\n"
			outHandle.write(text)

			read1 = readsFolder + "/" + file
			
			text = "/net/isi-dcnl/ifs/user_data/Seq/FastQC/fastqc -o "+fastqcFolder+" " + read1 + "\n"
			outHandle.write(text)
			
			fastqcPrefix = re.sub(".fastq","",file)
			
			zipReport = fastqcFolder + "/" + fastqcPrefix + "_fastqc.zip"
			#htmlReport = fastqcFolder + "/" + fastqcPrefix + "_fastqc.html"
			
			text = "rm "+zipReport + "\n"
			outHandle.write(text)
			
			#text = "rm "+htmlReport + "\n"
			#outHandle.write(text)