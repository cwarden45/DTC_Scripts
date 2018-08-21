#!/bin/sh

BAM="/path/to/alignment.bam"
PREFIXOUT="[processing description]"
REF="/path/to/hg19.fasta"
target_status=false #true for exome/panel, false for WGS
target_bed="/path/to/target.bed" #if using targeted sequencing


if ("$target_status")
then
	echo "Exome Variant Calling"
	
	echo "Calling variants for full .bam file"
	VCF=$PREFIXOUT\_FULL.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --nCPU=4 --bamFiles=$BAM --output=$VCF --refFile=$REF

	VCF=$PREFIXOUT\_FULL_ALT1.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --minVarFreq=0.3 --minReads=4 --nCPU=4 --bamFiles=$BAM --output=$VCF --refFile=$REF
	
	VCF=$PREFIXOUT\_FULL_ALT2.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --assemble=1 --minVarFreq=0.3 --minReads=4 --nCPU=4 --bamFiles=$BAM --output=$VCF --refFile=$REF

	
	echo "Filtering bam..."
	FILTERBAM=$(echo $BAM | sed 's/.bam/_TARGET.bam/')
	echo $FILTERBAM
	/sw/bedtools2/bin/bedtools intersect -abam $BAM -b $target_bed > $FILTERBAM
	/sw/samtools-1.3.1/samtools index $FILTERBAM
	
	echo "Calling (filtered) variants"
	VCF=$PREFIXOUT\_TARGET.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --nCPU=4 --bamFiles=$FILTERBAM --output=$VCF --refFile=$REF

	VCF=$PREFIXOUT\_TARGET_ALT1.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --minVarFreq=0.3 --minReads=4 --nCPU=4 --bamFiles=$FILTERBAM --output=$VCF --refFile=$REF
	
	VCF=$PREFIXOUT\_TARGET_ALT2.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --assemble=1 --minVarFreq=0.3 --minReads=4 --nCPU=4 --bamFiles=$FILTERBAM --output=$VCF --refFile=$REF
else	
	echo "WGS Variant Calling"

	VCF=$PREFIXOUT\_WGS.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --nCPU=4 --bamFiles=$BAM --output=$VCF --refFile=$REF

	VCF=$PREFIXOUT\_WGS_ALT1.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --minVarFreq=0.3 --minReads=4 --nCPU=4 --bamFiles=$BAM --output=$VCF --refFile=$REF
	
	VCF=$PREFIXOUT\_WGS_ALT2.vcf
	python /sw/Platypus_0.8.1/Platypus.py callVariants --assemble=1 --minVarFreq=0.3 --minReads=4 --nCPU=4 --bamFiles=$BAM --output=$VCF --refFile=$REF

fi
