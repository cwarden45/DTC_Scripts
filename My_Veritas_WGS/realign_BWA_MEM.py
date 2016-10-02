import sys
import re
import os
from Bio import SeqIO

bamIn = "veritas_wgs.bam"
bamOut = "BWA_MEM_Alignment/hg19.gatk.bam"
gatkRefId = "hg19"
bwaThreads = "2"
fastqcThreads = "16"

for arg in sys.argv:
	bamInResult = re.search("^--bam_in=(.*)",arg)
	bamOutResult = re.search("^--bam_out=(.*)",arg)
	refResult = re.search("^--ref=(.*)",arg)
	threadsBwaResult = re.search("^--bwa_threads=(.*)",arg)
	threadsFastqcResult = re.search("^--fastqc_threads=(.*)",arg)
	helpResult = re.search("^--help",arg)
	
	if bamInResult:
		bamIn = bamInResult.group(1)
		
	if bamOutResult:
		bamOut = bamOutResult.group(1)

	if refResult:
		gatkRefId = refResult.group(1)
		
	if threadsBwaResult:
		bwaThreads = threadsBwaResult.group(1)

	if threadsFastqcResult:
		fastqcThreads = threadsFastqcResult.group(1)
		
	if helpResult:
		print "Usage: python run_BWA_MEM.py --bam_in=veritas_wgs.bam --bam_out=BWA_MEM_Alignment/hg19.gatk.bam --ref=hg19\n"
		print "--bam_in : Previous alignment file\n"
		print "--bam_out : BWA-MEM alignment file\n"
		print "--ref : Reference name (GATK fasta will be downloaded)\n"
		print "--bwa_threads : Threads to be used by BWA\n"
		print "--fastqc_threads : Threads to be used by FastQC\n"
		sys.exit()

if gatkRefId == "hg19":
	command = "wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/ucsc.hg19.fasta.gz"
	#os.system(command)
	
	refFa = "hg19.gatk.fasta"
	command = "gunzip ucsc.hg19.fasta.gz -c > " + refFa
	#os.system(command)
	
	command = "rm ucsc.hg19.fasta.gz"
	#os.system(command)
else:
	print "Need to provide mapping to download file for " + gatkRefId
	sys.exit()
	

print "\n\nSort by Read Name and Create Unique,Paired FASTQ Files\n\n"
folderResult = re.search("(.*)/",bamOut)
if folderResult:
	subfolder = folderResult.group(1)
	command = "mkdir " + subfolder
	#os.system(command)

nameBam = re.sub(".bam",".sort.bam",bamOut)
command = "/opt/samtools-1.3/samtools sort -n " + bamIn+ " -o " + nameBam
#os.system(command)

read1 = re.sub(".bam","_R1.fastq",bamIn)
read2 = re.sub(".bam","_R2.fastq",bamIn)
command = "/opt/samtools-1.3/samtools bam2fq -n " + nameBam + " -1 " + read1+ " -2 " + read2
#os.system(command)

#multi-mapped reads already collapsed, so don't need to run these commands
def unique_reads(records):
	prevRead = ""
	for rec in records:
		if rec.id != prevRead:
			yield rec
		prevRead = rec.id
#fastq_parser = SeqIO.parse(temp1, "fastq") 
#SeqIO.write(unique_reads(fastq_parser), read1, "fastq")

#fastq_parser = SeqIO.parse(temp2, "fastq") 
#SeqIO.write(unique_reads(fastq_parser), read2, "fastq")

command = "rm " + nameBam
os.system(command)

command = "gzip " + read1
os.system(command)

command = "gzip " + read2
os.system(command)

read1 = re.sub(".fastq",".fastq.gz",read1)
read2 = re.sub(".fastq",".fastq.gz",read2)

print "\n\nRun FastQC\n\n"
#each thread only allocated 250 MB
command = "/opt/FastQC/fastqc " + read1 + " -t " + fastqcThreads
os.system(command)
command = "/opt/FastQC/fastqc " + read2 + " -t " + fastqcThreads
os.system(command)

print "\n\nRun BWA-MEM\n\n"
command = "/opt/bwa/bwa index -a bwtsw " + refFa
os.system(command)

alnSam = re.sub(".bam",".sam",bamOut)
command = "/opt/bwa/bwa mem -t " + bwaThreads + " " + refFa + " " + read1 + " " + read2 + " > " + alnSam
os.system(command)

print "\n\nSort and Index Alignment\n\n"
command = "/opt/samtools-1.3/samtools sort -O BAM " + alnSam+ " -o " + bamOut
os.system(command)

command = "rm " + alnSam
os.system(command)

command = "/opt/samtools-1.3/samtools index " + bamOut
os.system(command)

