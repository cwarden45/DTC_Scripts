import sys
import re
import os

FQ = "38721806153623_lcWGS.fastq.gz"
rgBam = "BWA_MEM.bam"
nodupBam = "BWA_MEM.nodup.bam"
refFa = "/home/cwarden/Ref/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa"
gatkRefId = "hg19"
bwaThreads = "4"
javaMem = "16g"

print "\n\nRun BWA-MEM\n\n"
alnSam = "temp.sam"
command = "/opt/bwa-0.7.17/bwa mem -t " + bwaThreads + " " + refFa + " " + FQ + " > " + alnSam
#os.system(command)

print "\n\nSam-to-Bam (to save space),Sort/Add-Read-Groups, and Remove-Duplicates/Index Alignment\n\n"
tempBam = "temp.bam"
command = "samtools view -b " + alnSam+ " > " + tempBam
#os.system(command)

command = "rm " + alnSam
#os.system(command)

command = "java -Xmx" + javaMem + " -jar /opt/picard-v2.21.9.jar AddOrReplaceReadGroups I=" + tempBam + " O=" + rgBam + " SO=coordinate RGID=1 RGLB=WGA RGPL=Illumina RGPU=Veritas RGSM=realign"
#os.system(command)

command = "rm " + tempBam
#os.system(command)

command = "samtools index " + rgBam
#os.system(command)

duplicateMetrics = "MarkDuplicates_BWA_MEM_metrics.txt"
command = "java -jar -Xmx" + javaMem + " /opt/picard-v2.21.9.jar MarkDuplicates INPUT=" + rgBam + " OUTPUT=" + nodupBam + " METRICS_FILE=" + duplicateMetrics + " REMOVE_DUPLICATES=true CREATE_INDEX=True"
os.system(command)
