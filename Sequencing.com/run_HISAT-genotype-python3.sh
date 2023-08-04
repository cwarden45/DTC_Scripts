#!/bin/bash

R1=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.1.fq.gz
R2=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.2.fq.gz
THREADS=4
OUTDIR=Sequencing.com_HISAT-genotype

#reference saved under /opt/hisat-genotype/indicies/hisatgenotype_db

export PATH=/opt/samtools:/opt/hisat2-2.2.1:$PATH
export PYTHONPATH="$PYTHONPATH:/opt/hisat-genotype/hisatgenotype_modules"

python3 /opt/hisat-genotype/hisatgenotype --base hla --locus-list A,B,C,DRB1,DQA1,DQB1 -1 $R1 -2 $R2 -p $THREADS --out-dir $OUTDIR