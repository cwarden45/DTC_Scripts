#!/bin/bash

BAM=/opt/GLIMPSE/test/NA12878_1x_bam/NA12878.bam
OUTFOLDER=test

CHR=22
K1G_FOLDER=/home/cwarden/CDW_Genome/1000_Genomes_BAMs/GRCh38_positions
REF=$K1G_FOLDER/GRCh38_full_analysis_set_plus_decoy_hla.fa
THREADS=4

SITES=$K1G_FOLDER/ALL.chr$CHR\_GRCh38_sites.20170504.rename.vcf.gz
TSV=$K1G_FOLDER/ALL.chr$CHR\_GRCh38_sites.20170504.rename.tsv.gz
GENOREF=$K1G_FOLDER/ALL.chr$CHR\_GRCh38.genotypes.20170504.rename.vcf.gz
MAP=/opt/GLIMPSE/maps/genetic_maps.b38/chr$CHR.b38.gmap.gz

mkdir $OUTFOLDER
mkdir $OUTFOLDER/GLIMPSE_imputed
mkdir $OUTFOLDER/GLIMPSE_ligated
mkdir $OUTFOLDER/GLIMPSE_phased
VCF=$OUTFOLDER/NA12878.chr22.1x.vcf.gz

#convert 1st part of code to `rename_reference_chr.sh`, without removing test sample

######################################################################################################
#### this is what I will need to convert for my sample (for the full files, without ".noNA12878") ####
######################################################################################################

mkdir temp_folder

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_likelihoods

#BCF=temp_folder/1000GP.chr$CHR.noNA12878.sites.bcf.gz
#/opt/bcftools-1.10.2/bcftools mpileup -f ${REF} -I -E -a 'FORMAT/DP' -T $SITES -r chr$CHR -O b ${BAM} > $BCF
#/opt/bcftools-1.10.2/bcftools call -Aim --ploidy GRCh38 -C alleles -T ${TSV} -Oz -o $VCF $BCF
#/opt/bcftools-1.10.2/bcftools index -f $VCF
#rm $BCF

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_chunk

#/opt/GLIMPSE/chunk/bin/GLIMPSE_chunk --input $SITES --region chr$CHR --window-size 2000000 --buffer-size 200000 --output $OUTFOLDER/chunks.chr22.txt

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_phase

#follow https://www.unix.com/homework-and-coursework-questions/210357-shell-script-read-tab-delimited-file-perform-simple-tasks.html
#while read id chrC irg org c5 c6
#do
#	#can add leading 0s for a total of 2-3 digits in ID when converting code (above)
#	echo $id
#	echo $irg
#	echo $org
#	OUT=$OUTFOLDER/GLIMPSE_imputed/NA12878.chr22.1x.$id.bcf
#	/opt/GLIMPSE/phase/bin/GLIMPSE_phase --input ${VCF} --reference $GENOREF --map ${MAP} --input-region $irg --output-region $org --output ${OUT} --thread $THREADS
#	/opt/bcftools-1.10.2/bcftools index -f ${OUT}
#done < $OUTFOLDER/chunks.chr22.txt

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_ligate

#LST=$OUTFOLDER/GLIMPSE_ligated/list.chr22.txt
#ls $OUTFOLDER/GLIMPSE_imputed/NA12878.chr22.*.bcf > ${LST}
#OUT=$OUTFOLDER/GLIMPSE_ligated/NA12878.chr22.merged.bcf
#/opt/GLIMPSE/ligate/bin/GLIMPSE_ligate --input ${LST} --output $OUT
#/opt/bcftools-1.10.2/bcftools index -f ${OUT}

##https://odelaneau.github.io/GLIMPSE/tutorial.html#run_sample

VCF=$OUTFOLDER/GLIMPSE_ligated/NA12878.chr22.merged.bcf
OUT=$OUTFOLDER/GLIMPSE_phased/NA12878.chr22.phased.bcf
RESULT=$OUTFOLDER/GLIMPSE_phased/NA12878.chr22.phased.vcf
#/opt/GLIMPSE/sample/bin/GLIMPSE_sample --input ${VCF} --solve --output ${OUT}
#/opt/bcftools-1.10.2/bcftools index -f ${OUT}
/opt/bcftools-1.10.2/bcftools view $OUT > $RESULT