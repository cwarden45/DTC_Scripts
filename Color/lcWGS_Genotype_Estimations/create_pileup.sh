#!/bin/sh

BAM=BWA_MEM.nodup.bam
PILEUP=BWA_MEM.hg19.pileup
PILEUP2=BWA_MEM.hg19.C50.pileup
REF=/home/cwarden/Ref/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa

samtools mpileup -f $REF $BAM > $PILEUP
samtools mpileup -C50 -f $REF $BAM > $PILEUP2