import sys
import re
import os

RG = "'@RG\\tID:Neb10down\\tSM:lcWGS\\tPU:Nebula'"
FQ1 = "../Nebula/951023c1725b4b52b150c46469121abd_R1_down10.fastq.gz"
FQ2 = "../Nebula/951023c1725b4b52b150c46469121abd_R2_down10.fastq.gz"
rgBam = "BWA_MEM_down10.bam"
nodupBam = "BWA_MEM_down10.nodup.bam"

#make modifications based upon http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/20190405_NYGC_b38_pipeline_description.pdf

refFa = "/home/cwarden/CDW_Genome/1000_Genomes_BAMs/GRCh38_positions/GRCh38_full_analysis_set_plus_decoy_hla.fa"
gatkRefId = "hg38"
bwaThreads = "4"
javaMem = "16g"

print "\n\nRun BWA-MEM\n\n"
alnSam = "temp.sam"
command = "/opt/bwa-0.7.17/bwa mem -Y -R "+RG+" -t " + bwaThreads + " " + refFa + " " + FQ1+ " " + FQ2 + " > " + alnSam
os.system(command)

print "\n\nSam-to-Bam (to save space),Sort/Add-Read-Groups, and Remove-Duplicates/Index Alignment\n\n"
tempBam = "temp.bam"
command = "samtools view -b " + alnSam+ " > " + tempBam
os.system(command)

command = "rm " + alnSam
os.system(command)

command = "java -Xmx" + javaMem + " -jar /opt/picard-v2.21.9.jar FixMateInformation I=" + tempBam + " O=" + rgBam + " ADD_MATE_CIGAR=true SO=coordinate"
os.system(command)

##command = "java -Xmx" + javaMem + " -jar /opt/picard-v2.21.9.jar AddOrReplaceReadGroups I=" + tempBam + " O=" + rgBam + " SO=coordinate RGID=1 RGLB=WGA RGPL=Illumina RGPU=Nebula RGSM=lcWGS"
##os.system(command)

command = "rm " + tempBam
os.system(command)

command = "samtools index " + rgBam
os.system(command)

duplicateMetrics = "MarkDuplicates_BWA_MEM_metrics.txt"
command = "java -jar -Xmx" + javaMem + " /opt/picard-v2.21.9.jar MarkDuplicates INPUT=" + rgBam + " OUTPUT=" + nodupBam + " METRICS_FILE=" + duplicateMetrics + " REMOVE_DUPLICATES=true CREATE_INDEX=True"
os.system(command)
