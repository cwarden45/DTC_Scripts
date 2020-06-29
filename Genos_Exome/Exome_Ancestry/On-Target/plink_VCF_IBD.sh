#!/bin/bash

##manually filter non-autosomal chromosomes (without integer values, resulting in 9,423 genotypes)
PREFIX=../1000_genomes_20140502_plus_2-SNP-chip_plus_Mayo-Exome_plus_Genos-BWA-MEM-Exome_plus_Veritas_WGS


/opt/plink/plink2 --make-bed --vcf $PREFIX.vcf --out $PREFIX
/opt/plink/plink2 --make-king-table -bfile $PREFIX --out $PREFIX