#!/bin/bash

#PREFIX=Bastu-felCat9-GATK_plus_Gencove-down50x
PREFIX=Bastu-felCat9-GATK_plus_Gencove-down100x

/opt/plink2 --make-bed --vcf $PREFIX.vcf --out $PREFIX --allow-extra-chr

/opt/plink2 --make-king-table -bfile $PREFIX --out $PREFIX --allow-extra-chr