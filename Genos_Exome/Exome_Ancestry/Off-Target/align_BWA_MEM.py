import sys
import re
import os

#copied and modified from https://github.com/cwarden45/Bastu_Cat_Genome/tree/master/Basepaws_Notes (and then Nebula STITCH analysis)

read1 = "BWA-MEM_realign_NOT-CDS-flank_50000_R1.fastq"
read2 = "BWA-MEM_realign_NOT-CDS-flank_50000_R2.fastq"

bamOut = "../../1000_Genomes_BAMs/Genos-Exome_BWA-MEM_realign_NOT-CDS-flank_50000.bam"
refFa = "../../1000_Genomes_BAMs/Ref/human_g1k_v37.fasta"

bwaThreads = "4"
javaMem = "24g"

print "\n\nRun BWA-MEM\n\n"
alnSam = re.sub(".bam",".sam",bamOut)
command = "/opt/bwa-0.7.17/bwa mem -t " + bwaThreads + " " + refFa + " " + read1 + " " + read2 + " > " + alnSam
os.system(command)

print "\n\nSam-to-Bam (to save space),Sort/Add-Read-Groups, and Remove-Duplicates/Index Alignment\n\n"
tempBam = "temp.bam"
command = "samtools view -b " + alnSam+ " > " + tempBam
os.system(command)

command = "rm " + alnSam
os.system(command)

rgBam = re.sub(".bam$",".rg.bam",bamOut)
command = "java -Xmx" + javaMem + " -jar /opt/picard-v2.21.9.jar AddOrReplaceReadGroups I=" + tempBam + " O=" + rgBam + " SO=coordinate RGID=1 RGLB=WGA RGPL=Illumina RGPU=Veritas RGSM=realign"
os.system(command)

command = "rm " + tempBam
os.system(command)

tempDir = "tmp"
os.system("mkdir " + tempDir)

duplicateMetrics = "MarkDuplicates_BWA_MEM_metrics.txt"
command = "java -jar -Xmx" + javaMem + " -Djava.io.tmpdir="+tempDir+" /opt/picard-v2.21.9.jar MarkDuplicates INPUT=" + rgBam + " OUTPUT=" + bamOut + " METRICS_FILE=" + duplicateMetrics + " REMOVE_DUPLICATES=true CREATE_INDEX=True TMP_DIR="+tempDir
os.system(command)

command = "rm " + rgBam
os.system(command)

tempDir = "tmp"
os.system("rm -R " + tempDir)