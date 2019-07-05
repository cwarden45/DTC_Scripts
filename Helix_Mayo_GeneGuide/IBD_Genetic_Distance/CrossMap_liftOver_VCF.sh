#!/bin/bash

vcfIN=Helix_ExomePlus_variants_1550345278.vcf
vcfOUT=Helix_ExomePlus_variants_1550345278_hg19.vcf
ucscCHAIN=hg38ToHg19.over.chain
REF=hg19.fa

CrossMap.py vcf $ucscCHAIN $vcfIN $REF $vcfOUT