#!/bin/bash

for i in $(seq 1 1 22) X Y
do
   echo $i chr$i
done >> chr_names.txt

for i in $(seq 1 1 22) X Y
do
	echo "Working on chr$i ..."
	/opt/bcftools-1.10.2/bcftools annotate --rename-chrs chr_names.txt  -O z ALL.chr$i\_GRCh38.genotypes.20170504.vcf.gz > ALL.chr$i\_GRCh38.genotypes.20170504.rename.vcf.gz
	/opt/bcftools-1.10.2/bcftools index -f ALL.chr$i\_GRCh38.genotypes.20170504.rename.vcf.gz
	
	/opt/bcftools-1.10.2/bcftools view -G -m 2 -M 2 -v snps ALL.chr$i\_GRCh38.genotypes.20170504.rename.vcf.gz -Oz -o ALL.chr$i\_GRCh38_sites.20170504.rename.vcf.gz
	/opt/bcftools-1.10.2/bcftools index -f ALL.chr$i\_GRCh38_sites.20170504.rename.vcf.gz

	/opt/bcftools-1.10.2/bcftools query -f'%CHROM\t%POS\t%REF,%ALT\n' ALL.chr$i\_GRCh38_sites.20170504.rename.vcf.gz | bgzip -c > ALL.chr$i\_GRCh38_sites.20170504.rename.tsv.gz
	tabix -s1 -b2 -e2 ALL.chr$i\_GRCh38_sites.20170504.rename.tsv.gz
done
