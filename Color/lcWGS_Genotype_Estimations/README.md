I first tested a very simple strategy (looking for the presence of a variant or a reference match in at least one read, and defining the variant as heterozygous if it was present).  However, I couldn't do this for the Color lcWGS data (for the subset of 1000 Genomes variants that I was checking), and this showed a noticable loss in the relatedness estimates between my re-aligned Nebula lcWGS and SNP chip samples (producing kinship estimates of ~0.24, instead of a kinship estimate of ~0.50 between my 23and Me and Genes for Good SNP chips).  With accuracy genotypes that is more than you would expect by chance (and perhaps would be identifiable enough to say the results belonged to someone within a particular family), but I know that I can get a more accurate result from the provided Nebula lcWGS genotypes (and I think it is worth seeing what else I can do with low-coverage sequencing data).

**So, I thought I needed to instead see what I could accomplish with some imputation strategies.**  Since the strategy above wasn't very good at defining a starting set of genotypes, I needed to find strategies that start with FASTQ or BAM input files (and/or provide an alternative way to start with a small set of more accurate genotypes, upstream of imputation).  For example, you can see much better accuracy for my [imputed Nebula lcWGS genotypes](https://github.com/cwarden45/DTC_Scripts/blob/master/Nebula/Downsample_IBD/README.md), although that was also unacceptable in some [other ways](http://cdwscience.blogspot.com/2019/08/low-coverage-sequencing-is-not.html).

**NOTE:** I learned that Gencove has a [minimum threshold](https://github.com/cwarden45/DTC_Scripts/tree/master/Nebula/Gencove) to process samples, so I can't actually test processing my Color reads with Gencove.  However, I am trying to a better feel for *how much* worse the self-identification is as you go below 0.1x sequencing.

### Calculating Relatedness using STITCH (for Nebula, NOT Color reads)

**0a)** The [IMPUTE2 reference files](https://mathgen.stats.ox.ac.uk/impute/impute_v2.html#reference) need to be reformatted to work with STITCH (with `niterations = 1`).  To create the approproate position, legend, and hapotype files, you can use `filter_IMPUTE2_files.R`.

**0b)** I wrote code to be extra careful to avoid sequence in or near telomeres and centromeres.  You can download the centromere posistions that I used with `download_centromere.sh`

**0c)** I downloaded the same reference as the 1000 Genomes samples to make things as similar as possible.  While it was not as effective, you can see the code for the all-bams version of STITCH to see how I aligned and processed the alignment in `download_and_index_BWAref.sh` and `align_BWA_MEM.py` (within [this subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Nebula/Gencove/STITCH)).  That also mentions that I downloaded the reference sequence from here: ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/

**1)** STITCH imputations calcualted from reference sets using code like `run_STITCH.R` (*with 99 CEU reference samples*) or `run_STITCH-REF286.R` (*with 286 CEU+GBR+ACB reference samples*)

**2)** A combined imputed .vcf file is created using `extract_selected_genotypes-ref_segments.py`

**3)** Imputed genotypes are combined with SNP chip genotypes (for myself and 1000 Genomes) using `combine_VCF.pl`

**4)** plink file conversion and kinship/relatedness estimate calculated using  using `plink_VCF_IBD.sh`

**5)** result reformatted using `plot-and-filter_king_values_V2.R`
