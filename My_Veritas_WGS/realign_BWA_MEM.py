import sys
import re
import os
from Bio import SeqIO

bamIn = "veritas_wgs.bam"
bamOut = "BWA_MEM_Alignment/hg19.gatk.bam"
gatkRefId = "hg19"
bwaThreads = "2"
javaMem = "4g"

for arg in sys.argv:
	bamInResult = re.search("^--bam_in=(.*)",arg)
	bamOutResult = re.search("^--bam_out=(.*)",arg)
	refResult = re.search("^--ref=(.*)",arg)
	threadsBwaResult = re.search("^--bwa_threads=(.*)",arg)
	memResult = re.search("^--java_mem=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if bamInResult:
		bamIn = bamInResult.group(1)
		
	if bamOutResult:
		bamOut = bamOutResult.group(1)

	if refResult:
		gatkRefId = refResult.group(1)
		
	if threadsBwaResult:
		bwaThreads = threadsBwaResult.group(1)

	if memResult:
		javaMem = memResult.group(1)
		
	if helpResult:
		print "Usage: python run_BWA_MEM.py --bam_in=veritas_wgs.bam --bam_out=BWA_MEM_Alignment/hg19.gatk.bam --ref=hg19\n"
		print "--bam_in : Previous alignment file\n"
		print "--bam_out : BWA-MEM alignment file\n"
		print "--ref : Reference name (GATK fasta will be downloaded)\n"
		print "--bwa_threads : Threads to be used by BWA\n"
		print "--java_mem : Memory Allocation for Picard\n"
		sys.exit()

if gatkRefId == "hg19":
	command = "wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/ucsc.hg19.fasta.gz"
	os.system(command)
	
	refFa = "hg19.gatk.fasta"
	command = "gunzip ucsc.hg19.fasta.gz -c > " + refFa
	os.system(command)
	
	command = "rm ucsc.hg19.fasta.gz"
	os.system(command)
else:
	print "Need to provide mapping to download file for " + gatkRefId
	sys.exit()
	

print "\n\nSort by Read Name and Create Unique,Paired FASTQ Files\n\n"
folderResult = re.search("(.*)/",bamOut)
if folderResult:
	subfolder = folderResult.group(1)
	command = "mkdir " + subfolder
	os.system(command)

nameBam = re.sub(".bam",".sort.bam",bamOut)
command = "/opt/samtools-1.3/samtools sort -n " + bamIn+ " -o " + nameBam
os.system(command)

read1 = re.sub(".bam","_R1.fastq",bamIn)
read2 = re.sub(".bam","_R2.fastq",bamIn)
unpaired = "unpaired.fastq"
command = "java -jar -Xmx" + javaMem + " /opt/picard-tools-2.5.0/picard.jar SamToFastq INPUT=" + nameBam + " FASTQ=" + read1 + " SECOND_END_FASTQ=" + read2 + " UNPAIRED_FASTQ=" + unpaired
os.system(command)

command = "rm " + nameBam
os.system(command)

command = "rm " + unpaired
os.system(command)

command = "gzip " + read1
os.system(command)
command = "gzip " + read2
os.system(command)
read1 = read1 + ".gz"
read2 = read2 + ".gz"

#better to run in parallel with GUI
#each thread only allocated 250 MB
#fastqcThreads = "16"
#command = "/opt/FastQC/fastqc " + read1 + " -t " + fastqcThreads
#os.system(command)
#command = "/opt/FastQC/fastqc " + read2 + " -t " + fastqcThreads
#os.system(command)

print "\n\nRun BWA-MEM\n\n"
command = "/opt/bwa/bwa index -a bwtsw " + refFa
os.system(command)

alnSam = re.sub(".bam",".sam",bamOut)
command = "/opt/bwa/bwa mem -t " + bwaThreads + " " + refFa + " " + read1 + " " + read2 + " > " + alnSam
os.system(command)

tempBam = "temp.bam"
command = "/opt/samtools-1.3/samtools view -b " + alnSam+ " > " + tempBam
os.system(command)

command = "rm " + alnSam
os.system(command)

command = "/opt/samtools-1.3/samtools sort " + tempBam+ " -o " + bamOut
os.system(command)

command = "rm " + tempBam
os.system(command)

command = "/opt/samtools-1.3/samtools index " + bamOut
os.system(command)
