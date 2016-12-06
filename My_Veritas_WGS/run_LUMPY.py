import sys
import re
import os

filteredBam = "veritas_wgs.filter.bam"
rgBam = "veritas_wgs.filter.rg.bam"

print "Adding Read Groups"
command = "java -jar -Xmx4g /opt/picard-tools-2.5.0/picard.jar AddOrReplaceReadGroups INPUT=" + filteredBam + " OUTPUT=" + rgBam + " RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=VeritasWGS"
os.system(command)

print "Extracting Discordant Paired-End Reads"
unsortedDiscord = "discordants.unsorted.bam"
command = "samtools view -b -F 1294 " + rgBam + " > " + unsortedDiscord
os.system(command)

print "Sorting Discordant PE Reads"
sortedDiscord = "discordant_reads.bam"
command = "samtools sort -o " + sortedDiscord + "  " + unsortedDiscord
os.system(command)

command = "rm " + unsortedDiscord
os.system(command)

print "Extracting Split Reads"
unsortedSplit = "split.unsorted.bam"
command = "samtools view -h " + rgBam + " | /opt/lumpy-sv/scripts/extractSplitReads_BwaMem -i stdin | samtools view -b - > " + unsortedSplit
os.system(command)

print "Sorting Split Reads"
sortedSplit = "split_reads.bam"
command = "samtools sort -o " + sortedSplit + "  " + unsortedSplit
os.system(command)

command = "rm " +  unsortedSplit
os.system(command)

print "Running LUMPY"
vcf = "LUMPY_SV.vcf"
command = "/opt/lumpy-sv/bin/lumpyexpress -B " + rgBam + " -S " + sortedSplit + " -D " + sortedDiscord + " -o " + vcf
os.system(command)
