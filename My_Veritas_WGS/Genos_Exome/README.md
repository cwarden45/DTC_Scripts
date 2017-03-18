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

*Step #8*) On the next screen, select the radio button for "Exons Plus [n] bases at each end" (where the default setting of n is 0)

*Step #9*) Click "get BED" to download your file

**Convert .bed File to .target_intervals for Picard**

### Other Notes ###

Unless specified differently above, I used scripts in [My_Veritas_WGS](https://github.com/cwarden45/DNAseq_templates/edit/master/My_Veritas_WGS) and/or [Exome_Workflow](https://github.com/cwarden45/DNAseq_templates/tree/master/Exome_Workflow) for analysis
