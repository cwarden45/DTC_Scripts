**Step 1)** plink_VCF_IBD.bash (after manually editing file)

**Step 2)** filter_ped_file.py (sample counts did not previously match)

**Step 3)** ped-to-pop.py (create .pop file for ADMIXTURE, for "supervised" mode)

**Step 4)** run_ADMIXTURE.bash

After running ADMIXTURE, I converted the file to Excel, and I determined which columns would best match which super-population