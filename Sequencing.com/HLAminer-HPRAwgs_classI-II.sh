#!/bin/bash

READ1=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.1.fq.gz
READ2=../CharlesWarden-NG1J8B7TDM-30x-WGS-Sequencing_com-10-13-21.2.fq.gz
REF=/opt/HLAminer-1.4/HLAminer_v1.4/database/HLA-I_II_GEN.fasta

### Run bwa or your favorite short read aligner
echo "Running bwa..."
#sudo /opt/bwa-0.7.17/bwa index -a bwtsw $REF
/opt/bwa-0.7.17/bwa mem -t 4 $REF $READ1 $READ2 > aln.sam
### Predict HLA
echo "Predicting HLA..."
/opt/HLAminer-1.4/HLAminer_v1.4/bin/HLAminer.pl -a aln.sam -h $REF -p /opt/HLAminer-1.4/HLAminer_v1.4/database/hla_nom_p.txt -s 500
