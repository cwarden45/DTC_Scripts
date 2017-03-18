### For Research Purposes Only! ###

The Genos website says that they used an [Agilent SureSelect Commercial](https://genos.co/sequencing.html) kit.  This is a commonly used platform, and kit information can be downloaded from [SureDesign](https://earray.chem.agilent.com/suredesign/).  However, you are supposed to register using a work e-mail (a personal G-mail account won't work), and there multiple types and versions of SureSelect kits.  So, as an approximation, I downloaded exon .bed files from the [UCSC Genome Browser](https://genome.ucsc.edu/), testing different flanking lengths for coverage approximations.

**Download hg19 Exon Locations in .bed Format**

*Step #1*) Go to the [UCSC Table Browser](https://genome.ucsc.edu/cgi-bin/hgTables)

*Step #2*) Make sure clade is "Mammal", genome is "human", and assembly is "Feb 2009 (GRCh37/hg19)"

*Step #3*) Select the type of gene annotation.  So, group should be "Genes and Gene Predictions" and the type of gene annotation is listed under the track pull-down.  I tested "RefSeq", "UCSC", and "GENCODE Genes V19".

*Step #4*) Make sure region is set to "genome"

*Step #5*) Select .bed output format

*Step #6*) Provide an output file name for "output file".  For example "RefSeq_genes_0bp_flanking.bed"

*Step #7*) Click "get output"

*Step #8*) On the next screen, select the radio button for the desired regions.

You can try "Exons Plus [n] bases at each end" (where the default setting of n is 0), but based upon visualization of the GAPDH gene, it looks like only CDS regions were covered.  So, the best representative coverage statistic will likely come from regions defined with "Coding Exons" (which I test in a table below).

*Step #9*) Click "get BED" to download your file

**Convert .bed File to .target_intervals for Picard**

I use [Picard](https://broadinstitute.github.io/picard/) for file-conversion and coverage statisics (and some down-stream steps).  You can download all the programs separately, but I'm providing instruction assuming that you are using my [dnaseq-dependencies](https://hub.docker.com/r/cwarden45/dnaseq-dependencies/) Docker image.  Please see the main  [My_Veritas_WGS](https://github.com/cwarden45/DNAseq_templates/edit/master/My_Veritas_WGS) README with some additional information about setting up Docker.

*Step #1*) If you have not done so already, you'll need to have downloaded a copy of the hg19 reference genome in FASTA format.  Please see the main  [My_Veritas_WGS](https://github.com/cwarden45/DNAseq_templates/edit/master/My_Veritas_WGS) README with some additional information about setting up Docker.

*Step #2*) If you have downloaded the appropriate .bed file, you can create the interval list (which also creates the .dict file for the refernece, if it doesn't already exist) by running `python create_interval_file.py --input=targets.bed --ouput=targets.interval_list --ref=hg19.fa`.  If running the script within the downloaded folder, after the Veritas WGS scripts, the RefSeq gene interval list would be created with the command `python create_interval_file.py --input=RefSeq_genes_CDS.bed --output=RefSeq_genes_CDS.interval_list --ref=../hg19.karyotype.fasta`

Please note that reference should be karyotpe-ordered (starting with chrM), to match provided alignment reference (or if using GATK functions on a new alignment from the .fasta files).

You can type `python create_interval_file.py --help` for more information.

**Coverage Metrics for Provided .bam Alignment File**

If you've created the appropriate .interval_list file, you can calculate coverage statistics by running `python calculate_coverage_statistics.py --alignment=sample.bam --intervals=targets.interval_list --ref=hg19.fa`.  If running the script within the downloaded folder, after the Veritas WGS scripts, the RefSeq gene interval list would be created with the command `python calculate_coverage_statistics.py --alignment=[sampleID].mapped.sorted.markdup.realn.recal --intervals=RefSeq_genes_CDS.interval_list --ref=../hg19.fasta`.  By default, the prefix for the output is the concatination of the name for the .bam file and the .interval_list file, but this can be manually specified using `--output_prefix=prefix`.

| Annotation | Flanking | Avg Cov | Percent 10x | Percent 20x |
|---|---|---|---|---|
|RefSeq CDS|0 bp||||
|RefSeq Exon|0 bp||||
|RefSeq Exon|200 bp|---|---|---|
|UCSC CDS|0 bp|---|---|---|
|UCSC Exon|0 bp|---|---|---|
|UCSC Exon|200 bp|---|---|---|
|GENCODE CDS|0 bp|---|---|---|
|GENCODE Exon|0 bp|---|---|---|
|GENCODE Exon|200 bp|---|---|---|

*CDS = Coding exons

**Re-Align Reads and Re-Call Variants**

**Filter Off-Target Variants**

Shouldn't really matter for non-synonymous mutations in known genes, but you'll probably want non-coding regulatory variants within target regions. 

### Other Notes ###

Unless specified differently above, I used scripts / strategies described in the main  [My_Veritas_WGS](https://github.com/cwarden45/DNAseq_templates/edit/master/My_Veritas_WGS) page.