import sys
import re
import os
import subprocess

#NOTE: I believe you can currently do something roughly similar with the DHFFC analysis in duphold: https://github.com/brentp/duphold and https://academic.oup.com/gigascience/article/8/4/giz040/5477467
#...which I believe is good for giving extra confidence in strategy (from both ends) :)

bed= ""
bam = "veritas_wgs.filter.bam"
statOut= ""
filterOut = ""
cutoff = 0.7
maxDel = 50000

for arg in sys.argv:
	bedResult = re.search("^--bed=(.*)",arg)
	bamResult = re.search("^--bam=(.*)",arg)
	covResult = re.search("^--cutoff=(.*)",arg)
	maxResult = re.search("^--max_length=(.*)",arg)
	statResult = re.search("^--stat=(.*)",arg)
	outResult = re.search("^--filtered=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if bedResult:
		bed = bedResult.group(1)

	if bamResult:
		bam = bamResult.group(1)
		
	if covResult:
		cutoff = float(covResult.group(1))

	if maxResult:
		maxDel = float(maxResult.group(1))
		
	if statResult:
		statOut = statResult.group(1)

	if outResult:
		filterOut = outResult.group(1)
		
	if helpResult:
		print "Usage: python DEL_cov_filter.py --bed=[file].bed  --bam=[alignment.bam] --cutoff=0.7 --max_length=50000 --stat=[file]_cov_stats.txt --filtered=[file]_filtered.bed\n"
		print "--bed : BED file with SV deletions\n"
		print "--bam : BAM alignment used for SV caller\n"
		print "--cutoff : Maximum coverage allowed in deletion region\n"
		print "--max_length : Maximum deletion size for breakpoint SV (probably needs to be less than 5kb in order to not see with coverage alone)\n"
		print "--stat : Coverage stats for all DEL\n"
		print "--filtered : SVs with max --cutoff coverage relative flanking\n"
		sys.exit()

if bam =="":
	print "Need to specify --bam file to calculate coverage"
	sys.exit()
		
if statOut == "":
	statOut = re.sub(".bed$","_cov_stats.txt",bed)
	print "Coverage statistics for all DEL calls in " + statOut
statOutHandle = open(statOut, 'w')
	
if filterOut == "":
	filterOut = re.sub(".bed$","_filtered.bed",bed)
	print "Filtered DEL calls in " + filterOut
filterOutHandle = open(filterOut, 'w')
		
inHandle = open(bed)
line = inHandle.readline()
			
totalReads = ""
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	
	try:
		chr = lineInfo[0]
		start = int(lineInfo[1])
		stop = int(lineInfo[2])
		ID = lineInfo[3]
		
		length = stop - start
		if (length > maxDel):
			print "Skipping " + ID + " due to implausibly large size (to be missed by IGV coverage)"
		else:
			print "...Calculating coverage for " + ID
			upStart = start - length - 1
			if upStart < 0:
				upStart = 0
			upStop = start - 1
			
			downStart = stop + 1
			downStop = stop + length + 1

			command = "/opt/samtools-1.3/samtools view " + bam + " " + chr + ":" + str(start) + "-" + str(stop) + " | wc -l"
			delCov = int(subprocess.check_output(command, shell=True))
			
			command = "/opt/samtools-1.3/samtools view " + bam + " " + chr + ":" + str(upStart) + "-" + str(upStop) + " | wc -l"
			upCov = int(subprocess.check_output(command, shell=True))
			
			command = "/opt/samtools-1.3/samtools view " + bam + " " + chr + ":" + str(downStart) + "-" + str(downStop) + " | wc -l"
			downCov = int(subprocess.check_output(command, shell=True))
			
			ratio = float(delCov) / float((upCov + downCov)/2)
			
			text = chr + "\t" + str(start) + "\t" + str(stop) + "\t" + ID + "\t" + '{:.2f}'.format(ratio) + "\n"
			statOutHandle.write(text)
			
			if ratio <= cutoff:
				text = chr + "\t" + str(start) + "\t" + str(stop) + "\t" + ID + "\t" + '{:.2f}'.format(ratio) + "\n"
				filterOutHandle.write(text)			
	except ValueError:
		print "Skipping " + line

	line = inHandle.readline()	
