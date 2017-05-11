#!/bin/bash

READ1=read1.fastq.gz
READ2=read2.fastq.gz
REF=/opt/bwa.kit/hs38DH.fa

OUT_PREFIX=genos_exome

THREADS=4

STEP2=full_command.sh

#follow instructions at https://github.com/lh3/bwa/tree/master/bwakit to download and index reference

/opt/bwa.kit/run-bwamem -o $OUT_PREFIX -R '@RG\tID:genos_exome\tSM:unknown' -t $THREADS -a -d -k -H $REF $READ1 $READ2 > $STEP2
sh $STEP2

#information about interpreting the top HLA file is available here: https://www.biostars.org/p/222030/
#there is also some additional general information about BWA HLA typing here: https://github.com/lh3/bwa/blob/master/README-alt.md
