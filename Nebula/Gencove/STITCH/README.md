### Downloading reference low-coverage Whole Genome Sequencing .bam data

***1)*** I searched for "human low-coverage Whole Genome Sequencing" in the [SRA](https://www.ncbi.nlm.nih.gov/sra/?term=human+low-coverage+whole+genome+sequencing), and then filtering for runs with **.bam** files available

***2)*** I then clicked "Send results to Run selector" to view those results in the [SRA Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/?)

***3)*** I exported the meta data, and I then filtered for runs with 200Mbp to 500Mbp of 200 bp spots.  I then created another file where I kept the smallest .bam file for each unique HapMap_sample_ID (for a total of 56 reference samples from different individuals).  I also added a few extra samples from already reprsented individuals, for comparison.  Along wtih removing some extra JPT and TSI individuals, that resulted in a set of **28 samples** to test.

***4)*** With the run numbers (and knowledge that .bam files existed), I downloaded .bam files for alignments to all chromosmes from the [ENA](https://www.ebi.ac.uk/ena)
