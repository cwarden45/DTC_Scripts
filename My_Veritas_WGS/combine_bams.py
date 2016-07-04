import sys
import re
import os

bamFolder = "chr_bam"
javaMem = "4g"
threads = "1"

for arg in sys.argv:
	replacementResult = re.search("^--bam_folder=(.*)",arg)
	memResult = re.search("^--java_mem=(.*)",arg)
	threadsResult = re.search("^--threads=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if replacementResult:
		bamFolder = replacementResult.group(1)

	if memResult:
		javaMem = memResult.group(1)

	if threadsResult:
		threads = threadsResult.group(1)
		
	if helpResult:
		print "Usage: python combine_bams.py --bam_folder=chr_bam --java_mem=4g --threads=1\n"
		print "--bam_folder : Folder containing per-chromosome .bam files\n"
		print "--java_mem : Java memory limit for Picard\n"
		print "--threads : Number of Threads - must be less than Docker CPU\n"
		sys.exit()

folderContents = os.listdir(bamFolder)

bamFiles = []
for file in folderContents:
	bamMatch = re.search(".bam$",file)
	if bamMatch:
		bamFiles.append(os.path.join(bamFolder, file))

print "Merging contents of " + bamFolder + " folder"
mergedBam = "veritas_wgs.bam"
command = "/opt/samtools-1.3/samtools merge " + mergedBam + " " + " ".join(bamFiles)
os.system(command)

print "Sort .bam File"
sortedBam = "veritas_wgs.sort.bam"
command = "/opt/samtools-1.3/samtools sort --threads " + threads + " -o " + sortedBam + " " + mergedBam
os.system(command)

print "Remove Duplicates and Re-Index .bam File"
#Separate chromosome .bam files had some reads from other chromosomes
#So, I want to make sure I don't count intra-chromosomal or multi-mapping reads more than once
#...in addition to removing any PCR duplicates
filteredBam = "veritas_wgs.sort.filter.bam"
duplicateMetrics = "MarkDuplicates_metrics.txt"
command = "java -jar -Xmx" + javaMem + " /opt/picard-tools-2.5.0/picard.jar MarkDuplicates INPUT=" + sortedBam + " OUTPUT=" + filteredBam + " METRICS_FILE=" + duplicateMetrics + " REMOVE_DUPLICATES=true CREATE_INDEX=True"
os.system(command)

print "Calculate WGS QC Metrics"
wgsMetrics = "WGS_metrics_querySorted.txt"
command = "java -jar -Xmx" + javaMem + " /opt/picard-tools-2.5.0/picard.jar CollectWgsMetricsFromQuerySorted I=" + filteredBam + " O=" + wgsMetrics
os.system(command)