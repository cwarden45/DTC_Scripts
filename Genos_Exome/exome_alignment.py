import sys
import re
import os

read_prefix = ""
interval = ""
ref = ""
threads = 2
output_prefix = "BWA-MEM_realign"
javaMem = "4g"


for arg in sys.argv:
	replacementResult = re.search("^--bam_folder=(.*)",arg)
	memResult = re.search("^--java_mem=(.*)",arg)
	threadsResult = re.search("^--threads=(.*)",arg)
	inputResult = re.search("^--read_prefix=(.*)",arg)
	intervalResult = re.search("^--intervals=(.*)",arg)
	outputResult = re.search("^--output_prefix=(.*)",arg)
	refResult = re.search("^--ref=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if replacementResult:
		bamFolder = replacementResult.group(1)

	if threadsResult:
		threads = threadsResult.group(1)
		
	if memResult:
		javaMem = memResult.group(1)

	if inputResult:
		read_prefix = inputResult.group(1)

	if intervalResult:
		interval = intervalResult.group(1)
		
	if outputResult:
		output_prefix = outputResult.group(1)

	if refResult:
		ref = refResult.group(1)
		
	if helpResult:
		print "Usage: python exome_alignment.py --read_prefix=sampleID --intervals=targets.interval_list --ref=ref.fa --output_prefix=BWA-MEM_realign --java_mem=4g --threads=2\n"
		print "--read_prefix : You sample ID.  Reads are [sampleID]_read[n].fastq.gz, n=1 for forward, 2 for reverse\n"
		print "--intervals : .interal_list file for target regions\n"
		print "--ref : Reference FASTA (must end with .fa or .fasta)\n"
		print "--output_prefix : prefix for output files\n"
		print "--java_mem : Java memory limit for Picard and GATK\n"
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
	
#make sure target regions were specified
intervalResult = re.search("(.*).interval_list$",interval)
if intervalResult == "":
	print "Must specify interval file, ending with .interval_list !"
	print "Provided Interval File: " + interval
	sys.exit()
else:
	interval_name = intervalResult.group(1)

#define align reads
print "Indexing Reference..."
command = "/opt/bwa/bwa index -a bwtsw " + ref
os.system(command)

print "Aligning Reads using BWA-MEM..."
read1 = read_prefix + "_read1.fastq.gz"
read2 = read_prefix + "_read2.fastq.gz"
alnSam = "aligned.sam"
command = "/opt/bwa/bwa mem -t "+ str(threads) + " " + ref + " " + read1 + " " + read2  + " > " + alnSam
os.system(command)

print "Sort and Add Read Groups..."
rgBam =  "rg.bam"
command = "java -Xmx" + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar AddOrReplaceReadGroups I=" + alnSam + " O=" + rgBam + " SO=coordinate RGID=1 RGLB=Exome-Seq RGPL=Illumina RGPU=unknown RGCN=Genos RGSM=Exome"
os.system(command)

command = "rm " + alnSam
os.system(command)

print "Calculating Full Alignment Stats..."
statsFile = output_prefix + "_alignment_stats.txt"
command = "samtools flagstat " + rgBam + " > " + statsFile
os.system(command)

print "Marking and Removing Duplicates..."
duplicateMetrics = output_prefix + "_MarkDuplicates_metrics.txt"
filteredBam = output_prefix + ".bam"
command = "java -Xmx" + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar MarkDuplicates I=" + rgBam + " O=" + filteredBam + " M=" + duplicateMetrics+" REMOVE_DUPLICATES=true CREATE_INDEX=true"
os.system(command)
			
command = "rm " + rgBam
os.system(command)

print "Sample Statistics Post-Duplicate Removal..."
statsFile = output_prefix + "_alignment_stats_no_dup.txt"
command = "samtools flagstat " + filteredBam + " > " + statsFile
os.system(command)

statFile = output_prefix + "_idxstats_no_dup.txt"
command = "samtools idxstats " + filteredBam + " > " + statFile
os.system(command)		
	
covPrefix = output_prefix + interval_name
targetMetrics = covPrefix + "_HsMetrics_coverage_stats_no_dup.txt"
targetMetrics2 = covPrefix + "_HsMetrics_coverage_stats_per_target_no_dup.txt"
command = "java -Xmx" + javaMem + " -jar /opt/picard-tools-2.5.0/picard.jar CalculateHsMetrics I=" + filteredBam + " O=" + targetMetrics + " PER_TARGET_COVERAGE=" + targetMetrics2 + " R=" + ref + " BAIT_INTERVALS=" + interval + " TARGET_INTERVALS=" + interval
os.system(command)
