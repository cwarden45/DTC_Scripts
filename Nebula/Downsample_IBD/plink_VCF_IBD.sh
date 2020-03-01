#!/bin/bash

#PREFIX=1000_genomes_20140502_plus_2-SNP-chip_plus_Veritas_plus_Nebula
PREFIX=1000_genomes_20140502_plus_2-SNP-chip_plus_Veritas_plus_Nebula_down10

/opt/plink2 --make-bed --vcf $PREFIX.vcf --out $PREFIX

/opt/plink2 --make-king-table -bfile $PREFIX --out $PREFIX
