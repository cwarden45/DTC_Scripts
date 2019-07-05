#!/bin/sh

BAM=82651510240740.mapped.sorted.markdup.realn.recal.bam
gVCF=82651510240740.mapped.sorted.markdup.realn.recal.gVCF
REF=../hg19.gatk.fasta

/opt/gatk-4.1.2.0/gatk --java-options -Xmx6g HaplotypeCaller --input $BAM --reference $REF --output $gVCF --dont-use-soft-clipped-bases true --emit-ref-confidence GVCF