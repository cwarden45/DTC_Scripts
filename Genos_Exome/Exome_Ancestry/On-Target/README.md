**Step 1)** filter_ped-and-vcf_file.py (sample counts did not previously match; also filters "X", "Y" and "M" chromosomes)

**Step 2)** plink_VCF_IBD.sh

**Step 3)** ped-to-pop.py (create .pop file for [ADMIXTURE](http://software.genetics.ucla.edu/admixture/), for "supervised" mode)

**Step 4)** run_ADMIXTURE.bash

After running ADMIXTURE, I converted the file to Excel, and I determined which columns would best match which super-population
