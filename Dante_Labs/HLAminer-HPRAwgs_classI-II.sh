#!/bin/bash

FQ=../GFX0457625_SL_L001_001.reads.1_1.fastq.gz
REF=/opt/HLAminer-1.4/HLAminer_v1.4/database/HLA-I_II_GEN.fasta

### Run bwa or your favorite short read aligner
echo "Running bwa..."
#sudo /opt/bwa-0.7.17/bwa index -a bwtsw $REF
/opt/bwa-0.7.17/bwa mem -t 4 $REF $FQ > aln.sam
### Predict HLA
echo "Predicting HLA..."
/opt/HLAminer-1.4/HLAminer_v1.4/bin/HLAminer.pl -a aln.sam -h $REF -p /opt/HLAminer-1.4/HLAminer_v1.4/database/hla_nom_p.txt -s 500
