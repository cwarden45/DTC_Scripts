**Step 0)** Step up reference files

I mostly followed the instructions [here](https://odelaneau.github.io/GLIMPSE/installation.html).

However, I noticed that the hg38 UCSC chromosomes (with the "chr" in their name) where different than in the example .bam file.

So, I tried downloading the [GRCh38Decoy](https://support.illumina.com/sequencing/sequencing_software/igenome.html) files from iGenome.

These files are compressed in a different way than the other files.

So, if I use `unzip` to decompress them, I get an error message that is described in [this discussion group](https://unix.stackexchange.com/questions/183452/error-trying-to-unzip-file-need-pk-compat-v6-1-can-do-v4-6).

Namely, there is a UNIX version of 7zip that can be installed using `sudo apt-get install p7zip-full p7zip-rar` and it can be used to decompress the file using `7za x Homo_sapiens_NCBI_GRCh38Decoy.zip`.

This worked, but it took longer than I was expecting.

**However, I think this is still not exactly the reference used.**  If you look towards the bottom of the documentation, [this link](https://www.internationalgenome.org/data-portal/data-collection/30x-grch38) is referenced.  That refers to a reference sequence that can be downloaded from ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa

**Step 1)** Re-align reads

I slightly modified the code for the STITCH analysis to add `-K 100000000` for the BWA-MEM alignment.

While the strategy here is inhertently different (since the goal is to impute genotypes with lcWGS, rather than call variangs with 30x WGS), I checked the pre-processing steps described [here](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/20190405_NYGC_b38_pipeline_description.pdf).

**Step 2)** Run GLIMPSE