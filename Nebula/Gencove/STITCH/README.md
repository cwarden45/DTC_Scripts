***NOTE*: I get an error message if I try to run the reference-based imputation with the smaller number of sites.  On my computer, using the recommended set of variants caused an error message due to insufficient memory.**  However, for others running this analysis with the much larger number of sites from the [IMPUTE2 reference set](https://mathgen.stats.ox.ac.uk/impute/impute_v2.html#reference), as recommended by the [developer](https://github.com/rwdavies/STITCH/issues/29), I think there can probably be improvements in performance.

***If I run STITCH with substantially fewer variants, it completes running but the results were not very good.***  So, I am focusing more on the reference-guided implementation of STITCH, whose code can be seen [here](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations).

### Downloading reference low-coverage Whole Genome Sequencing .bam data

***1)*** I searched for "human low-coverage Whole Genome Sequencing" in the [SRA](https://www.ncbi.nlm.nih.gov/sra/?term=human+low-coverage+whole+genome+sequencing), and then filtering for runs with **.bam** files available

***2)*** I then clicked "Send results to Run selector" to view those results in the [SRA Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/?)

***3)*** I exported the meta data, and I then filtered for runs with 200Mbp to 500Mbp of 200 bp spots.  I then created another file where I kept the smallest .bam file for each unique HapMap_sample_ID (for a total of 56 reference samples from different individuals).  I also added a few extra samples from already reprsented individuals, for comparison.  Along wtih removing some extra JPT and TSI individuals, that resulted in a set of **28 samples** to test.

***4)*** With the run numbers (and knowledge that .bam files existed), I downloaded .bam files for alignments to all chromosmes from the [ENA](https://www.ebi.ac.uk/ena)

As described on [this website](https://www.internationalgenome.org/category/reference/), I downloaded a matching hg19 reference (without "chr" in the chromosome names, and the extra sequences for a more similar alignment) in order to align my own sample using BWA-MEM.  

However, I had to use a slightly different link to download that file: ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/

### Calculating Relatedness (with reference set, NOT bams alone)

The code is actually within [this subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations)

**1)** STITCH imputations calculated from reference sets using code like `run_STITCH.R` (*with 99 CEU reference samples*) or `run_STITCH-REF286.R` (*with 286 CEU+GBR+ACB reference samples*)

**2)** A combined imputed .vcf file is created using `extract_selected_genotypes-ref_segments.py`

**3)** Imputed genotypes are combined with SNP chip genotypes (for myself and 1000 Genomes) using `combine_VCF.pl`

**4)** plink file conversion and kinship/relatedness estimate calculated using  using `plink_VCF_IBD.sh`

**5)** result reformatted using `plot-and-filter_king_values_V2.R`
