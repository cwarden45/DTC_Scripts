#!/bin/bash

PREFIX=GRCh38_full_analysis_set_plus_decoy_hla

samtools faidx $PREFIX.fa
java -jar -Xmx6g /opt/picard-v2.21.9.jar CreateSequenceDictionary R=$PREFIX.fa O=$PREFIX.dict
/opt/bwa-0.7.17/bwa index -a bwtsw $PREFIX.fa