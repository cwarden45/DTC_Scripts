import sys
import re
import os

filteredBam = "veritas_wgs.filter.bam"
javaMem = "-Xmx4g"

print "Create GASV Input"
command = "java -jar " + javaMem + " /opt/gasv/bin/BAMToGASV.jar " + filteredBam + " -GASVPro True"
os.system(command)

print "Run GASV"
gasvInput = filteredBam + ".gasv.in"
command = "java -jar " + javaMem + " /opt/gasv/bin/GASV.jar --output regions --minClusterSize 6 --readlength 150 --batch " + gasvInput
os.system(command)

print "Run GASVPro-CC"
gasvproParam = filteredBam + ".gasvpro.in"
clusters = filteredBam + ".gasv.in.clusters"
command = "/opt/gasv/bin/GASVPro-CC  " + gasvproParam + " " + clusters
os.system(command)

print "Pruning Clusters"
gasvproClusters = filteredBam + ".gasv.in.clusters.GASVPro.clusters"
command = "/opt/gasv/scripts/GASVPruneClusters.pl " + gasvproClusters
os.system(command)

print "Run GASVPro-graph"
gasvproGraphDir = "GASVPro-graph"
command = "mkdir " + gasvproGraphDir
os.system(command)
coverageFile = filteredBam + ".gasv.in.clusters.GASVPro.coverage"
command = "/opt/gasv/bin/GASVPro-graph  " + gasvproClusters + " " + coverageFile + " " + gasvproGraphDir + " 6"
os.system(command)

print "Run GASVPro-mcmc"
command = "/opt/gasv/bin/GASVPro-mcmc  " + gasvproParam + " " + gasvproGraphDir
os.system(command)

print "Reformat 3 sets of clusters"
prunedClusters = filteredBam + ".gasv.in.clusters.GASVPro.clusters.pruned.clusters"
command = "/opt/gasv/bin/convertClusters " + clusters
os.system(command)
command = "/opt/gasv/bin/convertClusters " + gasvproClusters
os.system(command)
command = "/opt/gasv/bin/convertClusters " + prunedClusters
os.system(command)

#create deletion bed (from pruned GASVPro-CC results)
#use maximum distance coordinates from clusters
deletionBed = "GASVPro_DEL.bed"
filterOutHandle = open(deletionBed, 'w')

inHandle = open(prunedClusters)
line = inHandle.readline()
			
totalReads = ""
			
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	type = lineInfo[7]
	commentResult = re.search("^#", line)
	
	if (not commentResult) and (type == "D"):
		clusterID = lineInfo[0]
		chr1 = int(lineInfo[1])
		if chr1 <= 22:
			chr1 = "chr" + str(chr1)
		elif chr1 == 23:
			chr1 = "chrX"
		elif chr1 == 24:
			chr1 = "chrY"
		else:
			print "Need to map " + str(chr1)
			sys.exit()
		startResult = re.search("(\d+),(\d+)",lineInfo[2])
		start1 = int(startResult.group(1))
		start2 = int(startResult.group(2))
		start = min(start1,start2)
		stopResult = re.search("(\d+),(\d+)",lineInfo[4])
		stop1 = int(stopResult.group(1))
		stop2 = int(stopResult.group(2))
		stop = max(stop1,stop2)
		
		supportingReads = lineInfo[5]
		
		text = chr1 + "\t" + str(start) + "\t" + str(stop) + "\t" + clusterID + "\t" + supportingReads + "\n"
		filterOutHandle.write(text)			

	line = inHandle.readline()	