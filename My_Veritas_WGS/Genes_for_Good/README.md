[Genes for Good](https://genesforgood.sph.umich.edu/) is crowd-sourced study on genetic variation using SNP chips.  So, it is similar to 23andMe, except it is free for participants and different types of results are provided (and the SNP chips are not identical).

My 23andMe sample is from several years ago, on their V3 chip.  My Genes for Good sample was collected a couple years ago.  So, I don't know exactly how the latest results would compare, but I've provided a Venn Diagram below showing the overlap of probes (based upon genomic position, which is similar but slightly better than using the probe name):

![Alt text](probe_position_overlap.png "SNP Chip Position Overlap")

Raw data is provided in a few different formats, including .vcf format and 23andMe raw data format.  So, most of the scripts for analyzing 23andMe data can also be applied to Genes for Good data.

So, I am going to mostly use this page for notes on HLA typing with my different genomics technologies.  Namely, there was a [recent study](https://www.ncbi.nlm.nih.gov/pubmed/28490672) using imputed HLA types from SNP chip data, so I would like to test how my own imputed results compare to those from Illumina DNA-Seq (mostly from Genos Exome .fastq files, since my Veritas WGS raw data was an alignment to the canonical chromosomes with a noticable drop in coverage in the highly variable HLA region).

For SNP chips, the [dbSNP](https://www.ncbi.nlm.nih.gov/projects/SNP/) rsIDs (often used as the probe name) rather than chromosomal position is used for some of the imputation programs.
