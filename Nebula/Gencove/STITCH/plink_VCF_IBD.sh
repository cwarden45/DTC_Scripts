#!/bin/bash

PREFIX=1000_genomes_20140502_plus_2-SNP-chip_plus_Nebula-STITCH-full

/opt/plink2 --make-bed --vcf $PREFIX.vcf --out $PREFIX

/opt/plink2 --make-king-table -bfile $PREFIX --out $PREFIX