**Step 0)** Select .bed file

I started using the RefSeq CDS regions.

Another option would be to use **add_flank.py**.

**Step 1)** **bedtools_filter-Picard_FASTQ.sh**

Extract off-target reads and convert to FASTQ (to align for STITCH reference sequence).

If needed or desired, you could further down-sample these reads for lcWGS imputation

**Step 2)** **align_BWA_MEM.py** (re-align FASTQ files)

This is from the [STITCH lcWGS subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations). 

**Step 3)** **run_STITCH.R**

This is from the [STITCH lcWGS subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations). 

**Step 4)** **extract_selected_genotypes-ref_segments.py**

This is from the [STITCH lcWGS subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations). 

**Step 5)** **combine_VCF.pl**

This is from the [STITCH lcWGS subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations). 

**Step 6)** **plink_VCF_IBD.sh**

This is from the [STITCH lcWGS subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations). 

**Step 7)** **plot-and-filter_king_values_V2.R**

This is from the [STITCH lcWGS subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Color/lcWGS_Genotype_Estimations). 

**Step 8)** **filter_ped-and-vcf_file.py** (sample counts did not previously match)

This is from the [On-Target Exome Ancestry subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Genos_Exome/Exome_Ancestry/On-Target). 

**Step 9)** Re-run **plink_VCF_IBD.sh**

**Step 10)** **ped-to-pop.py** (create .pop file for [ADMIXTURE](http://software.genetics.ucla.edu/admixture/), for "supervised" mode)

This is from the [On-Target Exome Ancestry subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Genos_Exome/Exome_Ancestry/On-Target). 

**Step 11)** **run_ADMIXTURE.bash**

After running ADMIXTURE, I converted the file to Excel, and I determined which columns would best match which super-population.

This is from the [On-Target Exome Ancestry subfolder](https://github.com/cwarden45/DTC_Scripts/tree/master/Genos_Exome/Exome_Ancestry/On-Target). 
