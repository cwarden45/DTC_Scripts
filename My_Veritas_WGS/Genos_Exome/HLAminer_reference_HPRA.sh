#!/bin/bash

READ1=/path/to/read1.fastq.gz
READ2=/path/to/read2.fastq.gz
REF=/opt/HLAminer_v1.3.1/database/HLA-I_II_GEN.fasta

### Run original BWA
#sudo /opt/bwa.kit/bwa index -a bwtsw $REF
echo "Running bwa..."
/opt/bwa.kit/bwa aln -t 4 $REF $READ1 > aln_test.1.sai
/opt/bwa.kit/bwa aln -t 4 $REF $READ2 > aln_test.2.sai
/opt/bwa.kit/bwa sampe -o 1000 $REF aln_test.1.sai aln_test.2.sai $READ1 $READ2 > aln.sam
### ...or run BWA_MEM
#/opt/bwa.kit/bwa mem -t 4 $REF $READ1 $READ2 > aln.sam


### Predict HLA
echo "Predicting HLA..."
/opt/HLAminer_v1.3.1/bin/HLAminer.pl -a aln.sam -h $REF -p /opt/HLAminer_v1.3.1/database/hla_nom_p.txt -s 500
