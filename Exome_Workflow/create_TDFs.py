import sys
import re
import os

igvtools = "/opt/igvtools_2.3.91/igvtools"
parameterFile = "parameters.txt"
finishedSamples = ()

alignmentFolder = ""
genome = ""

inHandle = open(parameterFile)
lines = inHandle.readlines()
			
for line in lines:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	param = lineInfo[0]
	value = lineInfo[1]

	if param == "genome":
		genome = value
	
	if param == "Alignment_Folder":
		alignmentFolder = value

inHandle.close()
		
if (genome == "") or (genome == "[required]"):
	print "Need to enter a value for 'genome'!"
	sys.exit()

if (alignmentFolder == "") or (alignmentFolder == "[required]"):
	print "Need to enter a value for 'Alignment_Folder'!"
	sys.exit()

fileResults = os.listdir(alignmentFolder)

for file in fileResults:
	bamResult = re.search("(.*).bam$",file)
	if bamResult:
		sample = bamResult.group(1)
		if sample not in finishedSamples:
			print sample
			fullPath = alignmentFolder + "/" + file

			tdf = fullPath + ".tdf"
			command = igvtools + " count -z 7 " + fullPath + " " + tdf + " " + genome
			os.system(command)