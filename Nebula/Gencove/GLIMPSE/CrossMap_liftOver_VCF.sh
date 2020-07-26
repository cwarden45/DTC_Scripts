#!/bin/bash

vcfIN=../STITCH_Gencove/1000_genomes_20140502_plus_2-SNP-chip.vcf
vcfOUT=../STITCH_Gencove/1000_genomes_20140502_plus_2-SNP-chip_hg38.vcf
ucscCHAIN=hg19ToHg38.over.chain
REF=/home/cwarden/CDW_Genome/1000_Genomes_BAMs/GRCh38_positions/GRCh38_full_analysis_set_plus_decoy_hla.fa

CrossMap.py vcf $ucscCHAIN $vcfIN $REF $vcfOUT