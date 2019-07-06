#!/bin/sh

BAM=hg19.gatk.bam
gVCF=hg19.gatk.gVCF
gVCF2=hg19.gatk.flagged.gVCF
REF=../hg19.gatk.fasta

/opt/gatk-4.1.2.0/gatk --java-options -Xmx6g HaplotypeCaller --input $BAM --reference $REF --output $gVCF --dont-use-soft-clipped-bases true --emit-ref-confidence GVCF
/opt/gatk-4.1.2.0/gatk --java-options -Xmx6g VariantFiltration --variant $gVCF --output $gVCF2 -window 35 -cluster 3 -filter-name QD -filter "QD < 2.0" -filter-name FS -filter "FS > 30.0"