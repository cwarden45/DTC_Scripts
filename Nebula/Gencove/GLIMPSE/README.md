**Step 0)** Step up reference files

I mostly followed the instructions [here](https://odelaneau.github.io/GLIMPSE/installation.html).

If you look towards the bottom of the documentation, [this link](https://www.internationalgenome.org/data-portal/data-collection/30x-grch38) is referenced.  That refers to a reference sequence that can be downloaded from ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa

***If you use those files, then you need to re-name the chromosomes in the 1000 Genomes genotype (and site) files.***  The [demo code](https://odelaneau.github.io/GLIMPSE/tutorial.html#run_reference_panel) shows how this can be done in sections **2.2** and **3.1**.

I modified this slightly (skipping the removal of the test sample) to create ``rename_reference_chr.sh`` (starting with sequences downloaded using `download_ref.sh`, and indexed using `index_BWAref.sh`).

**Step 1)** Re-align reads using `align_BWA_MEM.py`

I slightly modified the code for the STITCH analysis to add `-Y` for the BWA-MEM alignment, as well as add a step for the [Picard](https://gatk.broadinstitute.org/hc/en-us/articles/360036713471-FixMateInformation-Picard-) `FixMateInformation` command.

While the strategy here is inhertently different (since the goal is to impute genotypes with lcWGS, rather than call variangs with 30x WGS), I checked the pre-processing steps described [here](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/20190405_NYGC_b38_pipeline_description.pdf).

**Step 2)** Run GLIMPSE using `run_GLIMPSE.sh`

**Step 3)** Combine genotypes between chromosomes using `combine_chr_vcf.py`

This is similar to *extract_selected_genotypes.py* for the [STITCH analysis](https://github.com/cwarden45/DTC_Scripts/tree/master/Nebula/Gencove/STITCH).

**Step 4)** LiftOver genotypes to compare reference/observed genotypes

Use [CrossMap](http://crossmap.sourceforge.net/#convert-vcf-format-files), as described in [Helix/Mayo GeneGuide IBD/kinship section](https://github.com/cwarden45/DTC_Scripts/tree/master/Helix_Mayo_GeneGuide/IBD_Genetic_Distance).

**Step 5)** Create combined .vcf with imputed genotypes as well as reference/observed genotypes

**Step 6)** plink file conversion and kinship/relatedness estimate calculated using `using plink_VCF_IBD.sh`

This matches the [STITCH analysis](https://github.com/cwarden45/DTC_Scripts/tree/master/Nebula/Gencove/STITCH).

**Step 7)** result reformatted using `plot-and-filter_king_values_V2.R`

This matches the [STITCH analysis](https://github.com/cwarden45/DTC_Scripts/tree/master/Nebula/Gencove/STITCH).

------

**Other Notes**

I noticed that the hg38 UCSC chromosomes (with the "chr" in their name) were different than in the example .bam file.

So, I tried downloading the [GRCh38Decoy](https://support.illumina.com/sequencing/sequencing_software/igenome.html) files from iGenome.

These files are compressed in a different way than the other files.

So, if I use `unzip` to decompress them, I get an error message that is described in [this discussion group](https://unix.stackexchange.com/questions/183452/error-trying-to-unzip-file-need-pk-compat-v6-1-can-do-v4-6).

Namely, there is a UNIX version of 7zip that can be installed using `sudo apt-get install p7zip-full p7zip-rar` and it can be used to decompress the file using `7za x Homo_sapiens_NCBI_GRCh38Decoy.zip`.

This worked, but it took longer than I was expecting.

**However, I think this is still not exactly the reference used.**  Accordingly, I show different instructions above.
