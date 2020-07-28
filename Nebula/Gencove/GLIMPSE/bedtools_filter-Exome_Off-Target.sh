#!/bin/bash

BED=RefSeq_CDS_hg38-flank_50000.bed
OUT=BWA_MEM.nodup_NOT-CDS-flank_50000.bam
STAT=BWA_MEM.nodup_NOT-CDS-flank_50000_flagstat.txt


BAM=BWA_MEM.nodup.bam

/opt/bedtools2/bin/bedtools intersect -abam $BAM -b $BED -v > $OUT
samtools flagstat $OUT > $STAT
