#!/bin/bash

BAM=/opt/GLIMPSE/test/NA12878_1x_bam/NA12878.bam
OUTFOLDER=test

CHR=22
K1G_FOLDER=/home/cwarden/CDW_Genome/1000_Genomes_BAMs/GRCh38_positions
REF=$K1G_FOLDER/GRCh38_full_analysis_set_plus_decoy_hla.fa
THREADS=4

#### this part doesn't need to be converted for my sample ####

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_reference_panel

#for i in $(seq 1 1 22)
#do
#   echo $i chr$i
#done >> chr_names.txt

#CHR=22
#/opt/bcftools-1.10.2/bcftools annotate --rename-chrs chr_names.txt \
#			$K1G_FOLDER/ALL.chr${CHR}_GRCh38.genotypes.20170504.vcf.gz -Ou | \
#			/opt/bcftools-1.10.2/bcftools view -m 2 -M 2 -v snps -s ^NA12878 --threads 4 -Ob -o reference_panel/1000GP.chr22.noNA12878.bcf
#/opt/bcftools-1.10.2/bcftools index -f reference_panel/1000GP.chr22.noNA12878.bcf
#rm chr_names.txt

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_likelihoods
#/opt/bcftools-1.10.2/bcftools view -G -m 2 -M 2 -v snps reference_panel/1000GP.chr22.noNA12878.bcf -Oz -o reference_panel/1000GP.chr22.noNA12878.sites.vcf.gz
#/opt/bcftools-1.10.2/bcftools index -f reference_panel/1000GP.chr22.noNA12878.sites.vcf.gz

#/opt/bcftools-1.10.2/bcftools query -f'%CHROM\t%POS\t%REF,%ALT\n' reference_panel/1000GP.chr22.noNA12878.sites.vcf.gz | bgzip -c > reference_panel/1000GP.chr22.noNA12878.sites.tsv.gz
#tabix -s1 -b2 -e2 reference_panel/1000GP.chr22.noNA12878.sites.tsv.gz

######################################################################################################
#### this is what I will need to convert for my sample (for the full files, without ".noNA12878") ####
######################################################################################################

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_likelihoods

#BCF=reference_panel/1000GP.chr$CHR.noNA12878.sites.bcf.gz
#TSV=$K1G_FOLDER/ALL.chr$CHR\_GRCh38_sites.20170504.vcf.gz
#OUT=$OUTFOLDER/NA12878.chr$CHR.1x.vcf.gz
##skip "-T ${VCF}", so I don't use that (and just use the downloaded sites file)
#/opt/bcftools-1.10.2/bcftools mpileup -f ${REF} -I -E -a 'FORMAT/DP' -r chr$CHR -O b ${BAM} > $BCF
##test removing "-Ai", which produces a segmentation fault (even if it really is needed)
#/opt/bcftools-1.10.2/bcftools call -m --ploidy GRCh38 -C alleles -T ${TSV} -Oz -o ${OUT} $BCF
#/opt/bcftools-1.10.2/bcftools index -f ${OUT}
#rm $BCF

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_chunk

#/opt/GLIMPSE/chunk/bin/GLIMPSE_chunk --input reference_panel/1000GP.chr$CHR.noNA12878.sites.vcf.gz --region chr$CHR --window-size 2000000 --buffer-size 200000 --output $OUTFOLDER/chunks.chr22.txt

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_phase

VCF=$OUTFOLDER/NA12878.chr22.1x.vcf.gz
REF=$K1G_FOLDER/ALL.chr$CHR\_GRCh38.genotypes.20170504.vcf.gz #change for what I will actually use, versus .bcf listed for test (without checking concordance)
MAP=/opt/GLIMPSE/maps/genetic_maps.b38/chr22.b38.gmap.gz
mkdir $OUTFOLDER/GLIMPSE_imputed
#follow https://www.unix.com/homework-and-coursework-questions/210357-shell-script-read-tab-delimited-file-perform-simple-tasks.html
while read id chrC irg org c5 c6
do
	#can add leading 0s for a total of 2-3 digits in ID when converting code (above)
	OUT=$OUTFOLDER/GLIMPSE_imputed/NA12878.chr22.1x.$id.bcf
	/opt/GLIMPSE/phase/bin/GLIMPSE_phase --input ${VCF} --reference ${REF} --map ${MAP} --input-region $irg --output-region $org --output ${OUT} --thread $THREADS
	/opt/bcftools-1.10.2/bcftools index -f ${OUT}
done < $OUTFOLDER/chunks.chr22.txt

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_ligate

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_sample