import sys
import re
import os

bam = ""
interval = ""
ref = ""
output_prefix = ""
javaMem = "4g"


for arg in sys.argv:
	replacementResult = re.search("^--bam_folder=(.*)",arg)
	memResult = re.search("^--java_mem=(.*)",arg)
	inputResult = re.search("^--alignment=(.*)",arg)
	intervalResult = re.search("^--intervals=(.*)",arg)
	outputResult = re.search("^--output_prefix=(.*)",arg)
	refResult = re.search("^--ref=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if replacementResult:
		bamFolder = replacementResult.group(1)

	if memResult:
		javaMem = memResult.group(1)

	if inputResult:
		bam = inputResult.group(1)

	if intervalResult:
		interval = intervalResult.group(1)
		
	if outputResult:
		output_prefix = outputResult.group(1)

	if refResult:
		ref = refResult.group(1)
		
	if helpResult:
		print "Usage: python create_interval_file.py --alignment=alignment.bam --intervals=targets.interval_list --ref=ref.fa--java_mem=4g\n"
		print "--alignment : .bam alignment file(should be sorted and indexed)\n"
		print "--intervals : .interal_list file for target regions\n"
		print "--ref : Reference FASTA (must end with .fa or .fasta)\n"
		print "--output_prefix : prefix for coverage statistic output files\n"
		print "--java_mem : Java memory limit for Picard\n"
		sys.exit()

#create .dict file, if not already created 
faResult = re.search(".fa$",ref)
fastaResult = re.search(".fasta$",ref)

if fastaResult:
	dict = os.path.abspath(re.sub(".fasta$",".dict",ref))
	print "\nUsing .dict file: " + dict
elif faResult:
	dict = os.path.abspath(re.sub(".fa$",".dict",ref))
	print "\nUsing .dict file: " + dict
else:
	print ".dict index file created based upon FASTA ref name, which must end with .fa or .fasta"
	print "Provided Ref: " + ref
	sys.exit()

if not os.path.exists(dict):
	print "Creating .dict index for reference..."
	command = "java -Xmx" + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar CreateSequenceDictionary R=" + ref + " O=" + dict
	os.system(command)

#index reference, if needed
ref_index = ref + ".fai"

if not os.path.exists(ref_index):
	print "Creating samtools reference index..."
	command = "samtools faidx " + ref
	os.system(command)

#make sure output prefix is defined
if output_prefix == "":
	bamResult = re.search("(.*).bam$",bam)
	intervalResult = re.search("(.*).interval_list$",interval)
	
	if not bamResult:
		print "ERROR: .bam file must end with '.bam'"
		print "Provided .bam: " + bam
	if not intervalResult:
		print "ERROR: .interval_list file must end with '.interval_list'"
		print "Provided interval file: " + interval
	else:
		output_prefix = bamResult.group(1) + "_" + intervalResult.group(1)
		
#define coverage statistics
print "Calculating coverage statistics..."
targetMetrics = output_prefix + "_HsMetrics_coverage_stats.txt"
targetMetrics2 = output_prefix + "_HsMetrics_coverage_stats_per_target.txt"
command = "java -Xmx" + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar CalculateHsMetrics I=" + bam + " O=" + targetMetrics + " PER_TARGET_COVERAGE=" + targetMetrics2 + " R=" + ref + " BAIT_INTERVALS=" + interval + " TARGET_INTERVALS=" + interval
os.system(command)
