#!/bin/bash

PREFIX=1000_genomes_20140502_plus_2-SNP-chip


/opt/plink/plink2 --make-bed --vcf $PREFIX.vcf --out $PREFIX

/opt/plink/plink2 --make-king-table -bfile $PREFIX --out $PREFIX