#!/bin/bash

wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz
gunzip human_g1k_v37.fasta.gz
samtools faidx human_g1k_v37.fasta
java -jar -Xmx6g /opt/picard-v2.21.9.jar CreateSequenceDictionary R=human_g1k_v37.fasta O=human_g1k_v37.dict
/opt/bwa-0.7.17/bwa index -a bwtsw human_g1k_v37.fasta