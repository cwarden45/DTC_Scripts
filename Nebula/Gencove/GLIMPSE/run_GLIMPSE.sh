#!/bin/bash

BAM=BWA_MEM_down10.nodup.bam
OUTFOLDER=Nebula_down10

K1G_FOLDER=/home/cwarden/CDW_Genome/1000_Genomes_BAMs/GRCh38_positions
REF=$K1G_FOLDER/GRCh38_full_analysis_set_plus_decoy_hla.fa
THREADS=4

mkdir $OUTFOLDER
mkdir $OUTFOLDER/GLIMPSE_phased
mkdir $OUTFOLDER/GLIMPSE_ligated
mkdir $OUTFOLDER/GLIMPSE_imputed

for i in $(seq 1 1 22)
do
	CHR=chr$i
	echo "Working on $CHR..."
	
	SITES=$K1G_FOLDER/ALL.$CHR\_GRCh38_sites.20170504.rename.vcf.gz
	TSV=$K1G_FOLDER/ALL.$CHR\_GRCh38_sites.20170504.rename.tsv.gz
	GENOREF=$K1G_FOLDER/ALL.$CHR\_GRCh38.genotypes.20170504.rename.vcf.gz
	MAP=/opt/GLIMPSE/maps/genetic_maps.b38/$CHR.b38.gmap.gz
	
	##This is the input file for GLIMPSE (for a given chromosome)##
	#from https://odelaneau.github.io/GLIMPSE/tutorial.html#run_likelihoods
	VCF=$OUTFOLDER/$CHR.vcf.gz

	BCF=$OUTFOLDER/1000GP.$CHR.sites.bcf.gz
	/opt/bcftools-1.10.2/bcftools mpileup -f $REF -I -E -a 'FORMAT/DP' -T $SITES -r $CHR -O b $BAM > $BCF
	/opt/bcftools-1.10.2/bcftools call -Aim --ploidy GRCh38 -C alleles -T $TSV -Oz -o $VCF $BCF
	/opt/bcftools-1.10.2/bcftools index -f $VCF
	rm $BCF
	
	##GLIMPSE chunk: https://odelaneau.github.io/GLIMPSE/tutorial.html#run_chunk
	
	/opt/GLIMPSE/chunk/bin/GLIMPSE_chunk --input $SITES --region $CHR --window-size 2000000 --buffer-size 200000 --output $OUTFOLDER/chunks.$CHR.txt
	
	##GLIMPSE phase: https://odelaneau.github.io/GLIMPSE/tutorial.html#run_phase
	##I modified the folder names, which I think makes the output easier to find

	while read id chrC irg org c5 c6
	do
		#can add leading 0s for a total of 2-3 digits in ID when converting code (above)
		echo $id
		echo $irg
		echo $org
		OUT=$OUTFOLDER/GLIMPSE_phased/$CHR.$id.bcf
		/opt/GLIMPSE/phase/bin/GLIMPSE_phase --input $VCF --reference $GENOREF --map $MAP --input-region $irg --output-region $org --output $OUT --thread $THREADS
		/opt/bcftools-1.10.2/bcftools index -f $OUT
	done < $OUTFOLDER/chunks.$CHR.txt
	
	##GLIMPSE ligate: https://odelaneau.github.io/GLIMPSE/tutorial.html#run_ligate

	LST=$OUTFOLDER/GLIMPSE_ligated/list.$CHR.txt
	ls $OUTFOLDER/GLIMPSE_phased/$CHR.*.bcf > $LST
	OUT=$OUTFOLDER/GLIMPSE_ligated/$CHR.merged.bcf
	/opt/GLIMPSE/ligate/bin/GLIMPSE_ligate --input $LST --output $OUT
	/opt/bcftools-1.10.2/bcftools index -f $OUT
	
	##GLIMPSE sample: https://odelaneau.github.io/GLIMPSE/tutorial.html#run_sample
	##I modified the folder names, which I think makes the output easier to find
	
	##This produces the output file (per chromosome)
	VCF=$OUTFOLDER/GLIMPSE_ligated/$CHR.merged.bcf
	OUT=$OUTFOLDER/GLIMPSE_imputed/$CHR.sample.bcf
	RESULT=$OUTFOLDER/GLIMPSE_imputed/$CHR.sample.vcf
	/opt/GLIMPSE/sample/bin/GLIMPSE_sample --input $VCF --solve --output $OUT
	/opt/bcftools-1.10.2/bcftools index -f $OUT
	/opt/bcftools-1.10.2/bcftools view $OUT > $RESULT
done

#to be similar to the STITCH code, I will combine the imputed genotypes in a separate script