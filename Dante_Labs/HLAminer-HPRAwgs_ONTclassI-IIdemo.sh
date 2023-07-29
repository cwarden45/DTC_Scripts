#!/bin/bash

FQ=../GFX0457625_SL_L001_001.reads.1_1.fastq.gz
REF1=/opt/HLAminer-1.4/HLAminer_v1.4/database/GCA_000001405.15_GRCh38_genomic.chr-only-noChr6-HLA-I_II_GEN.fa.gz
REF2=/opt/HLAminer-1.4/HLAminer_v1.4/database/HLA-I_II_GEN.fasta

### Run minimap2  or your favorite short read aligner
echo "Running minimap2 ..."
#Reference downloaded using: wget http://www.bcgsc.ca/downloads/btl/hlaminer/GCA_000001405.15_GRCh38_genomic.chr-only-noChr6-HLA-I_II_GEN.fa.gz
#General Index Command: sudo /opt/minimap2/minimap2 -d REF.mmi REF.fa
#HOWEVER, reference can be used withour prior indexing.
/opt/minimap2/minimap2 -a -t 4 -ax map-hifi --MD $REF1 $FQ  > aln.sam
### Predict HLA
echo "Predicting HLA..."
/opt/HLAminer-1.4/HLAminer_v1.4/bin/HLAminer.pl -a aln.sam -h $REF2 -q 1 -i 1 -p /opt/HLAminer-1.4/HLAminer_v1.4/database/hla_nom_p.txt -s 500
echo "Additional files for samtools idxstats summary"
/opt/samtools/samtools view -b aln.sam > aln.bam
#java -Xmx8g -jar /opt/picard-v2.21.9.jar AddOrReplaceReadGroups I=aln.bam O=rg.bam SO=coordinate RGID=1 RGLB=HiFi RGPL=PacBio RGPU=DanteLabs RGSM=realign
/opt/samtools/samtools sort -o sort.bam aln.bam
/opt/samtools/samtools index sort.bam
/opt/samtools/samtools idxstats sort.bam > idxstats.txt
