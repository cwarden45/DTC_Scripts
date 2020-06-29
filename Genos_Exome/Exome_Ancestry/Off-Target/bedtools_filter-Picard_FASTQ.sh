#!/bin/bash

#BED=../RefSeq_genes_CDS.bed
#OUT=BWA-MEM_realign_NOT-CDS.bam
#STAT=BWA-MEM_realign_NOT-CDS_flagstat.txt
#FQ1=BWA-MEM_realign_NOT-CDS_R1.fastq
#FQ2=BWA-MEM_realign_NOT-CDS_R2.fastq

#BED=../RefSeq_genes_CDS-flank_2000.bed
#OUT=BWA-MEM_realign_NOT-CDS-flank_2000.bam
#STAT=BWA-MEM_realign_NOT-CDS-flank_2000_flagstat.txt
#FQ1=BWA-MEM_realign_NOT-CDS-flank_2000_R1.fastq
#FQ2=BWA-MEM_realign_NOT-CDS-flank_2000_R2.fastq

##may want to consider using these reads and down-sampling them
BED=../RefSeq_genes_CDS-flank_10000.bed
OUT=BWA-MEM_realign_NOT-CDS-flank_10000.bam
STAT=BWA-MEM_realign_NOT-CDS-flank_10000_flagstat.txt
FQ1=BWA-MEM_realign_NOT-CDS-flank_10000_R1.fastq
FQ2=BWA-MEM_realign_NOT-CDS-flank_10000_R2.fastq

#BED=../RefSeq_genes_CDS-flank_50000.bed
#OUT=BWA-MEM_realign_NOT-CDS-flank_50000.bam
#STAT=BWA-MEM_realign_NOT-CDS-flank_50000_flagstat.txt
#FQ1=BWA-MEM_realign_NOT-CDS-flank_50000_R1.fastq
#FQ2=BWA-MEM_realign_NOT-CDS-flank_50000_R2.fastq


BAM=../BWA-MEM_realign.bam

/opt/bedtools2/bin/bedtools intersect -abam $BAM -b $BED -v > $OUT
samtools flagstat $OUT > $STAT

samtools fastq -1 $FQ1 -2 $FQ2 -0 /dev/null -s /dev/null $OUT